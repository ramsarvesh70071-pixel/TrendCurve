import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/extracted_table_model.dart';
import '../models/variable_metadata.dart';

class PdfParserService {
  /// Parses PDF bytes and extracts structured tabular data.
  Future<List<ExtractedTableModel>> parsePdfBytes(
    Uint8List bytes, {
    String fileName = 'document.pdf',
  }) async {
    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final textExtractor = PdfTextExtractor(document);
      final pageCount = document.pages.count;

      final fullTextBuffer = StringBuffer();
      for (int i = 0; i < pageCount; i++) {
        final pageText = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
        fullTextBuffer.writeln(pageText);
      }

      final extractedText = fullTextBuffer.toString();
      final tables = _extractTablesFromText(extractedText, fileName);

      if (tables.isEmpty) {
        throw Exception(
          'No structured table data was detected in this PDF. Please ensure the PDF contains tabular text.',
        );
      }

      return tables;
    } catch (e) {
      if (e.toString().contains('No structured table')) rethrow;
      throw Exception('Failed to parse PDF: ${e.toString()}');
    } finally {
      document?.dispose();
    }
  }

  /// Parses raw text into rows and detects columns
  List<ExtractedTableModel> _extractTablesFromText(String text, String sourceName) {
    final rawLines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (rawLines.isEmpty) return [];

    final tables = <ExtractedTableModel>[];
    final currentBlockLines = <String>[];

    for (final line in rawLines) {
      if (_isRowCandidate(line)) {
        currentBlockLines.add(line);
      } else if (currentBlockLines.isNotEmpty) {
        if (currentBlockLines.length >= 2) {
          final table = _processBlockIntoTable(
            currentBlockLines,
            'Table ${tables.length + 1} (${sourceName.replaceAll('.pdf', '')})',
          );
          if (table != null) tables.add(table);
        }
        currentBlockLines.clear();
      }
    }

    if (currentBlockLines.length >= 2) {
      final table = _processBlockIntoTable(
        currentBlockLines,
        'Table ${tables.length + 1} (${sourceName.replaceAll('.pdf', '')})',
      );
      if (table != null) tables.add(table);
    }

    // Fallback: If no distinct blocks were segmented, treat all candidate lines as one table
    if (tables.isEmpty && rawLines.length >= 2) {
      final fallbackTable = _processBlockIntoTable(
        rawLines,
        'Main Data (${sourceName.replaceAll('.pdf', '')})',
      );
      if (fallbackTable != null) tables.add(fallbackTable);
    }

    return tables;
  }

  bool _isRowCandidate(String line) {
    if (line.contains('\t') || line.contains('|') || line.contains(',')) {
      return true;
    }
    // Multiple whitespace separation (2+ spaces)
    return RegExp(r'\s{2,}').hasMatch(line);
  }

  ExtractedTableModel? _processBlockIntoTable(List<String> lines, String name) {
    if (lines.length < 2) return null;

    final parsedRows = <List<String>>[];
    for (final line in lines) {
      final cells = _splitLineIntoCells(line);
      if (cells.length >= 2) {
        parsedRows.add(cells);
      }
    }

    if (parsedRows.length < 2) return null;

    // Harmonize columns count based on majority row length
    final lengths = parsedRows.map((r) => r.length).toList();
    final counts = <int, int>{};
    for (final len in lengths) {
      counts[len] = (counts[len] ?? 0) + 1;
    }
    int expectedCols = lengths.first;
    int maxFreq = 0;
    counts.forEach((len, freq) {
      if (freq > maxFreq) {
        maxFreq = freq;
        expectedCols = len;
      }
    });

    final validRows = parsedRows.where((r) => r.length == expectedCols).toList();
    if (validRows.length < 2) return null;

    // Header row
    final rawHeaders = validRows.first;
    final headers = _sanitizeHeaders(rawHeaders);
    final dataRows = validRows.sublist(1);

    // Compute column metadata
    final metadata = <String, VariableMetadata>{};
    for (int col = 0; col < headers.length; col++) {
      final colName = headers[col];
      final colValues = dataRows.map((r) => r[col]).toList();

      final detectedType = _detectColumnType(colValues);
      int validCount = 0;
      int missingCount = 0;

      for (final val in colValues) {
        final clean = val.trim();
        if (clean.isEmpty || clean == '-' || clean == 'N/A' || clean == 'null') {
          missingCount++;
        } else {
          validCount++;
        }
      }

      metadata[colName] = VariableMetadata(
        name: colName,
        type: detectedType,
        totalValues: colValues.length,
        validValuesCount: validCount,
        missingValuesCount: missingCount,
        isNumeric: detectedType == ColumnDataType.numeric,
      );
    }

    return ExtractedTableModel(
      id: 'table_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      headers: headers,
      rows: dataRows,
      columnMetadata: metadata,
    );
  }

  List<String> _splitLineIntoCells(String line) {
    if (line.contains('|')) {
      return line.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
    }
    if (line.contains('\t')) {
      return line.split('\t').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
    }
    if (line.contains(RegExp(r'\s{2,}'))) {
      return line.split(RegExp(r'\s{2,}')).map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
    }
    if (line.contains(',')) {
      return line.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
    }
    return [line.trim()];
  }

  List<String> _sanitizeHeaders(List<String> rawHeaders) {
    final seen = <String, int>{};
    final cleaned = <String>[];

    for (int i = 0; i < rawHeaders.length; i++) {
      var h = rawHeaders[i].trim();
      if (h.isEmpty) h = 'Column_${i + 1}';
      if (seen.containsKey(h)) {
        seen[h] = seen[h]! + 1;
        cleaned.add('${h}_${seen[h]}');
      } else {
        seen[h] = 1;
        cleaned.add(h);
      }
    }
    return cleaned;
  }

  ColumnDataType _detectColumnType(List<String> values) {
    int numericMatches = 0;
    int dateMatches = 0;
    int totalEvaluated = 0;

    for (final v in values) {
      final clean = v.trim();
      if (clean.isEmpty || clean == '-' || clean == 'N/A') continue;

      totalEvaluated++;
      if (_parseNumeric(clean) != null) {
        numericMatches++;
      }
      if (_parseDate(clean) != null) {
        dateMatches++;
      }
    }

    if (totalEvaluated == 0) return ColumnDataType.text;
    if (numericMatches / totalEvaluated >= 0.7) return ColumnDataType.numeric;
    if (dateMatches / totalEvaluated >= 0.7) return ColumnDataType.date;
    return ColumnDataType.text;
  }

  double? _parseNumeric(String val) {
    final stripped = val
        .replaceAll(RegExp(r'[\$,₹,€,£,¥,%]'), '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(stripped);
  }

  DateTime? _parseDate(String val) {
    final dt = DateTime.tryParse(val);
    if (dt != null) return dt;

    final formats = [
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'yyyy/MM/dd',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'dd MMM yyyy',
      'MMM dd, yyyy',
    ];

    for (final f in formats) {
      try {
        return DateFormat(f).parseStrict(val);
      } catch (_) {}
    }
    return null;
  }

  /// Built-in rich sample datasets for instant demonstration
  static List<ExtractedTableModel> getSampleDatasets() {
    // 1. Industrial Sensor Metrics
    final sensorHeaders = ['Date', 'Temperature', 'Pressure', 'Voltage', 'Current', 'Status'];
    final sensorRows = [
      ['01/01/2026', '25.0', '1012.0', '230.0', '5.2', 'Normal'],
      ['02/01/2026', '27.4', '1014.5', '232.0', '5.5', 'Normal'],
      ['03/01/2026', '29.1', '1011.0', '235.0', '5.8', 'Warning'],
      ['04/01/2026', '28.3', '1013.2', '233.5', '5.6', 'Normal'],
      ['05/01/2026', '31.5', '1008.4', '238.0', '6.2', 'High'],
      ['06/01/2026', '33.2', '1006.1', '241.0', '6.7', 'Critical'],
      ['07/01/2026', '30.0', '1010.5', '236.0', '5.9', 'Warning'],
      ['08/01/2026', '26.8', '1015.0', '231.0', '5.3', 'Normal'],
      ['09/01/2026', '24.5', '1016.8', '229.5', '5.1', 'Normal'],
      ['10/01/2026', '26.0', '1014.0', '231.5', '5.4', 'Normal'],
    ];

    // 2. Financial Metrics
    final financeHeaders = ['Month', 'Revenue', 'Expenses', 'Net Profit', 'Profit Margin %'];
    final financeRows = [
      ['Jan 2026', '45000', '32000', '13000', '28.8'],
      ['Feb 2026', '52000', '34500', '17500', '33.6'],
      ['Mar 2026', '48000', '33000', '15000', '31.2'],
      ['Apr 2026', '61000', '37000', '24000', '39.3'],
      ['May 2026', '67500', '40200', '27300', '40.4'],
      ['Jun 2026', '74000', '42500', '31500', '42.5'],
      ['Jul 2026', '82000', '46000', '36000', '43.9'],
      ['Aug 2026', '79500', '45100', '34400', '43.2'],
      ['Sep 2026', '89000', '48000', '41000', '46.0'],
      ['Oct 2026', '95000', '51200', '43800', '46.1'],
    ];

    final parser = PdfParserService();

    final sensorMetadata = <String, VariableMetadata>{};
    for (int col = 0; col < sensorHeaders.length; col++) {
      final name = sensorHeaders[col];
      final colVals = sensorRows.map((r) => r[col]).toList();
      final type = parser._detectColumnType(colVals);
      sensorMetadata[name] = VariableMetadata(
        name: name,
        type: type,
        totalValues: colVals.length,
        validValuesCount: colVals.length,
        missingValuesCount: 0,
        isNumeric: type == ColumnDataType.numeric,
      );
    }

    final financeMetadata = <String, VariableMetadata>{};
    for (int col = 0; col < financeHeaders.length; col++) {
      final name = financeHeaders[col];
      final colVals = financeRows.map((r) => r[col]).toList();
      final type = parser._detectColumnType(colVals);
      financeMetadata[name] = VariableMetadata(
        name: name,
        type: type,
        totalValues: colVals.length,
        validValuesCount: colVals.length,
        missingValuesCount: 0,
        isNumeric: type == ColumnDataType.numeric,
      );
    }

    return [
      ExtractedTableModel(
        id: 'sample_sensor',
        name: 'Industrial Sensor Log (Temperature / Voltage / Current)',
        headers: sensorHeaders,
        rows: sensorRows,
        columnMetadata: sensorMetadata,
      ),
      ExtractedTableModel(
        id: 'sample_finance',
        name: 'Financial Performance (Revenue / Expenses / Net Profit)',
        headers: financeHeaders,
        rows: financeRows,
        columnMetadata: financeMetadata,
      ),
    ];
  }
}

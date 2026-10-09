import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/extracted_table_model.dart';
import 'data_cleaner_service.dart';

class ExcelExporterService {
  /// Generates a multi-sheet .xlsx workbook and triggers sharing/saving
  Future<String> exportToExcel({
    required ExtractedTableModel table,
    required List<String> selectedColumns,
    required String? xAxisColumn,
    required Map<String, ProcessedChartSeries> processedSeries,
  }) async {
    final excel = Excel.createExcel();

    // 1. SHEET 1: Original Data
    const sheet1Name = 'Original Data';
    excel.rename('Sheet1', sheet1Name);
    final sheet1 = excel[sheet1Name];

    // Header row
    sheet1.appendRow(table.headers.map((h) => TextCellValue(h)).toList());
    // Data rows
    for (final row in table.rows) {
      sheet1.appendRow(row.map((cell) => TextCellValue(cell)).toList());
    }

    // 2. SHEET 2: Selected Variables
    const sheet2Name = 'Selected Variables';
    final sheet2 = excel[sheet2Name];

    final exportCols = <String>[];
    if (xAxisColumn != null && !selectedColumns.contains(xAxisColumn)) {
      exportCols.add(xAxisColumn);
    }
    exportCols.addAll(selectedColumns);

    sheet2.appendRow(exportCols.map((c) => TextCellValue(c)).toList());

    for (final row in table.rows) {
      final filteredRow = <CellValue>[];
      for (final col in exportCols) {
        final idx = table.headers.indexOf(col);
        if (idx >= 0 && idx < row.length) {
          filteredRow.add(TextCellValue(row[idx]));
        } else {
          filteredRow.add(TextCellValue(''));
        }
      }
      sheet2.appendRow(filteredRow);
    }

    // 3. SHEET 3: Trend Data
    const sheet3Name = 'Trend Data';
    final sheet3 = excel[sheet3Name];

    final xHeader = xAxisColumn ?? 'Index';
    final trendHeaders = <CellValue>[TextCellValue(xHeader)];
    for (final varName in selectedColumns) {
      trendHeaders.add(TextCellValue(varName));
    }
    sheet3.appendRow(trendHeaders);

    // Get max row length from series
    int maxPoints = 0;
    for (final s in processedSeries.values) {
      if (s.cleanedValues.length > maxPoints) {
        maxPoints = s.cleanedValues.length;
      }
    }

    for (int i = 0; i < maxPoints; i++) {
      final rowCells = <CellValue>[];
      // X label
      String xLabel = '${i + 1}';
      if (processedSeries.isNotEmpty &&
          processedSeries.values.first.xLabels.length > i) {
        xLabel = processedSeries.values.first.xLabels[i];
      }
      rowCells.add(TextCellValue(xLabel));

      for (final varName in selectedColumns) {
        final series = processedSeries[varName];
        if (series != null && i < series.cleanedValues.length) {
          rowCells.add(DoubleCellValue(series.cleanedValues[i]));
        } else {
          rowCells.add(TextCellValue(''));
        }
      }
      sheet3.appendRow(rowCells);
    }

    // 4. SHEET 4: Summary
    const sheet4Name = 'Summary';
    final sheet4 = excel[sheet4Name];

    sheet4.appendRow([
      TextCellValue('Variable Name'),
      TextCellValue('Minimum'),
      TextCellValue('Maximum'),
      TextCellValue('Average'),
      TextCellValue('Median'),
      TextCellValue('First Value'),
      TextCellValue('Last Value'),
      TextCellValue('Difference'),
      TextCellValue('Growth %'),
      TextCellValue('Trend Direction'),
      TextCellValue('Valid Values'),
      TextCellValue('Missing Values'),
    ]);

    for (final varName in selectedColumns) {
      final s = processedSeries[varName]?.summary;
      if (s != null) {
        sheet4.appendRow([
          TextCellValue(s.variableName),
          DoubleCellValue(s.min),
          DoubleCellValue(s.max),
          DoubleCellValue(double.parse(s.average.toStringAsFixed(2))),
          DoubleCellValue(double.parse(s.median.toStringAsFixed(2))),
          DoubleCellValue(s.firstValue),
          DoubleCellValue(s.lastValue),
          DoubleCellValue(double.parse(s.difference.toStringAsFixed(2))),
          TextCellValue('${s.percentageChange.toStringAsFixed(2)}%'),
          TextCellValue(s.direction.label),
          IntCellValue(s.validCount),
          IntCellValue(s.missingCount),
        ]);
      }
    }

    // Save to temp file
    final now = DateTime.now();
    final timeStr = DateFormat('yyyy-MM-dd_HH-mm').format(now);
    final fileName = 'trend_analysis_$timeStr.xlsx';

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to generate Excel file bytes');
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Share / Open native sheet
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        subject: 'Trend Analysis Excel Workbook',
        text: 'Exported Trend Analysis Excel workbook ($fileName)',
      ),
    );

    return filePath;
  }
}

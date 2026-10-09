import '../models/variable_metadata.dart';
import '../models/extracted_table_model.dart';
import '../models/trend_summary_model.dart';

class ProcessedChartSeries {
  final String variableName;
  final List<double?> originalValues;
  final List<double> cleanedValues;
  final List<String> xLabels;
  final TrendSummaryModel summary;

  const ProcessedChartSeries({
    required this.variableName,
    required this.originalValues,
    required this.cleanedValues,
    required this.xLabels,
    required this.summary,
  });
}

class DataCleanerService {
  /// Processes selected numeric columns according to cleaning strategy
  Map<String, ProcessedChartSeries> processData({
    required ExtractedTableModel table,
    required List<String> selectedColumns,
    String? xAxisColumn,
    CleaningOption cleaningOption = CleaningOption.ignoreMissing,
  }) {
    final result = <String, ProcessedChartSeries>{};

    final xColIndex = xAxisColumn != null ? table.headers.indexOf(xAxisColumn) : -1;
    final allXLabels = <String>[];

    for (int r = 0; r < table.rows.length; r++) {
      if (xColIndex >= 0 && xColIndex < table.rows[r].length) {
        allXLabels.add(table.rows[r][xColIndex]);
      } else {
        allXLabels.add('${r + 1}');
      }
    }

    for (final colName in selectedColumns) {
      final colIndex = table.headers.indexOf(colName);
      if (colIndex == -1) continue;

      final rawColValues = table.rows.map((r) => r[colIndex]).toList();
      final parsedDoubles = rawColValues.map(_tryParseDouble).toList();

      final cleanedSeries = _applyCleaning(
        parsedDoubles,
        allXLabels,
        cleaningOption,
      );

      final summary = _computeSummary(
        variableName: colName,
        rawValues: parsedDoubles,
        cleanedValues: cleanedSeries.cleaned,
      );

      result[colName] = ProcessedChartSeries(
        variableName: colName,
        originalValues: parsedDoubles,
        cleanedValues: cleanedSeries.cleaned,
        xLabels: cleanedSeries.xLabels,
        summary: summary,
      );
    }

    return result;
  }

  double? _tryParseDouble(String val) {
    final clean = val
        .replaceAll(RegExp(r'[\$,₹,€,£,¥,%]'), '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(clean);
  }

  _CleanedData _applyCleaning(
    List<double?> rawValues,
    List<String> xLabels,
    CleaningOption option,
  ) {
    final cleaned = <double>[];
    final labels = <String>[];

    switch (option) {
      case CleaningOption.ignoreMissing:
        for (int i = 0; i < rawValues.length; i++) {
          final v = rawValues[i];
          if (v != null) {
            cleaned.add(v);
            labels.add(xLabels[i]);
          }
        }
        break;

      case CleaningOption.treatAsZero:
        for (int i = 0; i < rawValues.length; i++) {
          cleaned.add(rawValues[i] ?? 0.0);
          labels.add(xLabels[i]);
        }
        break;

      case CleaningOption.interpolate:
        final temp = List<double?>.from(rawValues);
        // Linear interpolation for null gaps
        for (int i = 0; i < temp.length; i++) {
          if (temp[i] == null) {
            // Find prev valid
            int prevIdx = i - 1;
            while (prevIdx >= 0 && temp[prevIdx] == null) {
              prevIdx--;
            }
            // Find next valid
            int nextIdx = i + 1;
            while (nextIdx < temp.length && temp[nextIdx] == null) {
              nextIdx++;
            }

            if (prevIdx >= 0 && nextIdx < temp.length) {
              final y0 = temp[prevIdx]!;
              final y1 = temp[nextIdx]!;
              final fraction = (i - prevIdx) / (nextIdx - prevIdx);
              temp[i] = y0 + fraction * (y1 - y0);
            } else if (prevIdx >= 0) {
              temp[i] = temp[prevIdx];
            } else if (nextIdx < temp.length) {
              temp[i] = temp[nextIdx];
            } else {
              temp[i] = 0.0;
            }
          }
        }
        for (int i = 0; i < temp.length; i++) {
          cleaned.add(temp[i]!);
          labels.add(xLabels[i]);
        }
        break;
    }

    return _CleanedData(cleaned: cleaned, xLabels: labels);
  }

  TrendSummaryModel _computeSummary({
    required String variableName,
    required List<double?> rawValues,
    required List<double> cleanedValues,
  }) {
    if (cleanedValues.isEmpty) {
      return TrendSummaryModel(
        variableName: variableName,
        min: 0,
        max: 0,
        average: 0,
        median: 0,
        firstValue: 0,
        lastValue: 0,
        difference: 0,
        percentageChange: 0,
        direction: TrendDirectionType.stable,
        validCount: 0,
        missingCount: rawValues.length,
      );
    }

    double minVal = cleanedValues.first;
    double maxVal = cleanedValues.first;
    double sum = 0;

    for (final v in cleanedValues) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
      sum += v;
    }

    final avg = sum / cleanedValues.length;

    // Median
    final sorted = List<double>.from(cleanedValues)..sort();
    final mid = sorted.length ~/ 2;
    final median = sorted.length.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0;

    final firstVal = cleanedValues.first;
    final lastVal = cleanedValues.last;
    final diff = lastVal - firstVal;

    final pctChange = firstVal != 0.0 ? (diff / firstVal.abs()) * 100.0 : (lastVal != 0 ? 100.0 : 0.0);

    TrendDirectionType dir;
    if (pctChange > 0.5) {
      dir = TrendDirectionType.increasing;
    } else if (pctChange < -0.5) {
      dir = TrendDirectionType.decreasing;
    } else {
      dir = TrendDirectionType.stable;
    }

    final validCount = rawValues.where((v) => v != null).length;
    final missingCount = rawValues.length - validCount;

    return TrendSummaryModel(
      variableName: variableName,
      min: minVal,
      max: maxVal,
      average: avg,
      median: median,
      firstValue: firstVal,
      lastValue: lastVal,
      difference: diff,
      percentageChange: pctChange,
      direction: dir,
      validCount: validCount,
      missingCount: missingCount,
    );
  }
}

class _CleanedData {
  final List<double> cleaned;
  final List<String> xLabels;
  const _CleanedData({required this.cleaned, required this.xLabels});
}

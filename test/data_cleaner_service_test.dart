import 'package:flutter_test/flutter_test.dart';
import 'package:trend_curve/features/pdf_analyzer/models/extracted_table_model.dart';
import 'package:trend_curve/features/pdf_analyzer/models/trend_summary_model.dart';
import 'package:trend_curve/features/pdf_analyzer/models/variable_metadata.dart';
import 'package:trend_curve/features/pdf_analyzer/services/data_cleaner_service.dart';

void main() {
  group('DataCleanerService Tests', () {
    late DataCleanerService service;
    late ExtractedTableModel testTable;

    setUp(() {
      service = DataCleanerService();
      testTable = const ExtractedTableModel(
        id: 'table_test',
        name: 'Sensor Test Log',
        headers: ['Date', 'Temperature', 'Pressure', 'Status'],
        rows: [
          ['2026-01-01', '25.0', '1012', 'OK'],
          ['2026-01-02', '27.5', '1014', 'OK'],
          ['2026-01-03', '', '1016', 'ALERT'], // missing temperature
          ['2026-01-04', '30.0', '1018', 'OK'],
          ['2026-01-05', '35.0', '1020', 'OK'],
        ],
        columnMetadata: {
          'Date': VariableMetadata(
            name: 'Date',
            type: ColumnDataType.date,
            totalValues: 5,
            validValuesCount: 5,
            missingValuesCount: 0,
            isNumeric: false,
          ),
          'Temperature': VariableMetadata(
            name: 'Temperature',
            type: ColumnDataType.numeric,
            totalValues: 5,
            validValuesCount: 4,
            missingValuesCount: 1,
            isNumeric: true,
          ),
          'Pressure': VariableMetadata(
            name: 'Pressure',
            type: ColumnDataType.numeric,
            totalValues: 5,
            validValuesCount: 5,
            missingValuesCount: 0,
            isNumeric: true,
          ),
          'Status': VariableMetadata(
            name: 'Status',
            type: ColumnDataType.text,
            totalValues: 5,
            validValuesCount: 5,
            missingValuesCount: 0,
            isNumeric: false,
          ),
        },
      );
    });

    test('linear interpolation replaces missing value with midpoint', () {
      final processed = service.processData(
        table: testTable,
        selectedColumns: ['Temperature'],
        xAxisColumn: 'Date',
        cleaningOption: CleaningOption.interpolate,
      );

      expect(processed.containsKey('Temperature'), isTrue);
      final series = processed['Temperature']!;
      expect(series.cleanedValues.length, equals(5));

      // Row 1: 25.0, Row 2: 27.5, Row 3: interpolated between 27.5 and 30.0 = 28.75, Row 4: 30.0, Row 5: 35.0
      expect(series.cleanedValues[2], closeTo(28.75, 0.01));
    });

    test('treatAsZero sets missing value to 0.0', () {
      final processed = service.processData(
        table: testTable,
        selectedColumns: ['Temperature'],
        xAxisColumn: 'Date',
        cleaningOption: CleaningOption.treatAsZero,
      );

      final series = processed['Temperature']!;
      expect(series.cleanedValues[2], equals(0.0));
    });

    test('computes correct statistical summary and increasing trend direction', () {
      final processed = service.processData(
        table: testTable,
        selectedColumns: ['Pressure'],
        xAxisColumn: 'Date',
        cleaningOption: CleaningOption.ignoreMissing,
      );

      final series = processed['Pressure']!;
      final summary = series.summary;

      expect(summary.min, equals(1012.0));
      expect(summary.max, equals(1020.0));
      expect(summary.firstValue, equals(1012.0));
      expect(summary.lastValue, equals(1020.0));
      expect(summary.difference, equals(8.0));
      expect(summary.direction, equals(TrendDirectionType.increasing));
      expect(summary.validCount, equals(5));
      expect(summary.missingCount, equals(0));
    });
  });
}

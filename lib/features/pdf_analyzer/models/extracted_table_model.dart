import 'variable_metadata.dart';

class ExtractedTableModel {
  final String id;
  final String name;
  final List<String> headers;
  final List<List<String>> rows;
  final Map<String, VariableMetadata> columnMetadata;

  const ExtractedTableModel({
    required this.id,
    required this.name,
    required this.headers,
    required this.rows,
    required this.columnMetadata,
  });

  int get rowCount => rows.length;
  int get columnCount => headers.length;

  List<String> get numericColumns => headers
      .where((h) => columnMetadata[h]?.isNumeric == true)
      .toList();

  List<String> get dateColumns => headers
      .where((h) => columnMetadata[h]?.type == ColumnDataType.date)
      .toList();

  List<VariableMetadata> get columns => headers
      .map((h) =>
          columnMetadata[h] ??
          VariableMetadata(
            name: h,
            type: ColumnDataType.text,
            totalValues: rows.length,
            validValuesCount: rows.length,
            missingValuesCount: 0,
            isNumeric: false,
          ))
      .toList();

  String getCellValue(List<String> row, String header) {
    final idx = headers.indexOf(header);
    return (idx >= 0 && idx < row.length) ? row[idx] : '';
  }

  String? get defaultXAxisColumn {
    if (dateColumns.isNotEmpty) return dateColumns.first;
    return null; // Will fallback to row index
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'headers': headers,
        'rows': rows,
      };
}

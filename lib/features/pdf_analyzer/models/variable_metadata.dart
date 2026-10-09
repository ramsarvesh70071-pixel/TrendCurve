enum CleaningOption {
  ignoreMissing('Ignore missing values'),
  treatAsZero('Treat missing values as 0'),
  interpolate('Interpolate missing values');

  final String label;
  const CleaningOption(this.label);
}

enum ColumnDataType {
  numeric('Numeric'),
  date('Date / Time'),
  text('Text');

  final String label;
  const ColumnDataType(this.label);
}

class VariableMetadata {
  final String name;
  final ColumnDataType type;
  final int totalValues;
  final int validValuesCount;
  final int missingValuesCount;
  final bool isNumeric;

  const VariableMetadata({
    required this.name,
    required this.type,
    required this.totalValues,
    required this.validValuesCount,
    required this.missingValuesCount,
    required this.isNumeric,
  });
}

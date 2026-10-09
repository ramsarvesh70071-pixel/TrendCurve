enum TrendDirectionType {
  increasing('Increasing'),
  decreasing('Decreasing'),
  stable('Stable');

  final String label;
  const TrendDirectionType(this.label);
}

class TrendSummaryModel {
  final String variableName;
  final double min;
  final double max;
  final double average;
  final double median;
  final double firstValue;
  final double lastValue;
  final double difference;
  final double percentageChange;
  final TrendDirectionType direction;
  final int validCount;
  final int missingCount;

  const TrendSummaryModel({
    required this.variableName,
    required this.min,
    required this.max,
    required this.average,
    required this.median,
    required this.firstValue,
    required this.lastValue,
    required this.difference,
    required this.percentageChange,
    required this.direction,
    required this.validCount,
    required this.missingCount,
  });

  Map<String, dynamic> toMap() => {
        'Variable': variableName,
        'Min': min,
        'Max': max,
        'Average': average,
        'Median': median,
        'First': firstValue,
        'Last': lastValue,
        'Difference': difference,
        'Change %': percentageChange,
        'Direction': direction.label,
        'Valid Values': validCount,
        'Missing Values': missingCount,
      };
}

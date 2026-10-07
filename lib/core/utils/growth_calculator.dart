/// Enumeration for the direction of growth
enum TrendDirection {
  positive,
  negative,
  stable,
}

/// Statistics computed from a series of numerical values and timestamps.
class CalculatedStatistics {
  final double currentValue;
  final double startingValue;
  final double highestValue;
  final double lowestValue;
  final double averageValue;
  final double totalChange;
  final double growthPercentage;
  final TrendDirection direction;
  final String? bestPeriodLabel;
  final String? worstPeriodLabel;
  final String insightMessage;

  const CalculatedStatistics({
    required this.currentValue,
    required this.startingValue,
    required this.highestValue,
    required this.lowestValue,
    required this.averageValue,
    required this.totalChange,
    required this.growthPercentage,
    required this.direction,
    this.bestPeriodLabel,
    this.worstPeriodLabel,
    required this.insightMessage,
  });

  factory CalculatedStatistics.empty() {
    return const CalculatedStatistics(
      currentValue: 0,
      startingValue: 0,
      highestValue: 0,
      lowestValue: 0,
      averageValue: 0,
      totalChange: 0,
      growthPercentage: 0,
      direction: TrendDirection.stable,
      insightMessage: 'Add at least 2 data points to start generating growth insights.',
    );
  }
}

/// Utility for performing real mathematical trend calculations.
class GrowthCalculator {
  GrowthCalculator._();

  /// Calculates percentage growth between two numbers safely:
  /// ((current - previous) / previous) * 100
  static double calculateGrowth(double current, double previous) {
    if (previous == 0.0) {
      if (current == 0.0) return 0.0;
      return current > 0 ? 100.0 : -100.0;
    }
    return ((current - previous) / previous.abs()) * 100.0;
  }

  /// Determines if direction is positive, negative, or stable.
  /// Anything with absolute change under 0.01% is considered stable.
  static TrendDirection determineDirection(double growthPercentage) {
    if (growthPercentage.abs() < 0.01) {
      return TrendDirection.stable;
    }
    return growthPercentage > 0 ? TrendDirection.positive : TrendDirection.negative;
  }

  /// Calculates comprehensive statistics for a list of data entries:
  /// [entries] should be sorted chronologically or will be sorted by date.
  static CalculatedStatistics computeStats({
    required List<MapEntry<DateTime, double>> sortedEntries,
    required String trendName,
    String unit = '',
  }) {
    if (sortedEntries.isEmpty) {
      return CalculatedStatistics.empty();
    }

    if (sortedEntries.length == 1) {
      final singleVal = sortedEntries.first.value;
      return CalculatedStatistics(
        currentValue: singleVal,
        startingValue: singleVal,
        highestValue: singleVal,
        lowestValue: singleVal,
        averageValue: singleVal,
        totalChange: 0.0,
        growthPercentage: 0.0,
        direction: TrendDirection.stable,
        insightMessage: 'Baseline set at $unit${singleVal.toStringAsFixed(1)}. Add more points to track growth.',
      );
    }

    final startingValue = sortedEntries.first.value;
    final currentValue = sortedEntries.last.value;
    final totalChange = currentValue - startingValue;
    final growthPercentage = calculateGrowth(currentValue, startingValue);
    final direction = determineDirection(growthPercentage);

    double highest = -double.infinity;
    double lowest = double.infinity;
    double sum = 0.0;

    double maxPeriodDelta = -double.infinity;
    double minPeriodDelta = double.infinity;
    DateTime? bestPeriodDate;
    DateTime? worstPeriodDate;

    for (int i = 0; i < sortedEntries.length; i++) {
      final val = sortedEntries[i].value;
      sum += val;
      if (val > highest) highest = val;
      if (val < lowest) lowest = val;

      if (i > 0) {
        final delta = val - sortedEntries[i - 1].value;
        if (delta > maxPeriodDelta) {
          maxPeriodDelta = delta;
          bestPeriodDate = sortedEntries[i].key;
        }
        if (delta < minPeriodDelta) {
          minPeriodDelta = delta;
          worstPeriodDate = sortedEntries[i].key;
        }
      }
    }

    final average = sum / sortedEntries.length;

    // Previous period delta (last point vs second to last point)
    final prevVal = sortedEntries[sortedEntries.length - 2].value;
    final recentGrowth = calculateGrowth(currentValue, prevVal);

    String insight;
    final absGrowth = recentGrowth.abs().toStringAsFixed(1);
    if (recentGrowth > 0.01) {
      insight = 'Your $trendName increased by $absGrowth% compared with the previous period.';
    } else if (recentGrowth < -0.01) {
      insight = 'Your $trendName decreased by $absGrowth% compared with the previous period.';
    } else {
      insight = 'Your $trendName remained steady with 0.0% variance from the previous period.';
    }

    String? bestPeriodLabel;
    if (bestPeriodDate != null) {
      bestPeriodLabel = '${bestPeriodDate.month}/${bestPeriodDate.day} (+${maxPeriodDelta.toStringAsFixed(1)})';
    }

    String? worstPeriodLabel;
    if (worstPeriodDate != null) {
      worstPeriodLabel = '${worstPeriodDate.month}/${worstPeriodDate.day} (${minPeriodDelta.toStringAsFixed(1)})';
    }

    return CalculatedStatistics(
      currentValue: currentValue,
      startingValue: startingValue,
      highestValue: highest,
      lowestValue: lowest,
      averageValue: average,
      totalChange: totalChange,
      growthPercentage: growthPercentage,
      direction: direction,
      bestPeriodLabel: bestPeriodLabel,
      worstPeriodLabel: worstPeriodLabel,
      insightMessage: insight,
    );
  }
}

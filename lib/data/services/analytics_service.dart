import '../../core/utils/growth_calculator.dart';
import '../models/trend_model.dart';

class OverallAnalyticsSummary {
  final int totalTrends;
  final int totalDataPoints;
  final double averageGrowth;
  final TrendModel? bestPerformingTrend;
  final TrendModel? worstPerformingTrend;
  final int positiveTrendsCount;
  final int negativeTrendsCount;
  final int stableTrendsCount;
  final Map<String, double> categoryDistribution;
  final Map<String, int> categoryCounts;

  const OverallAnalyticsSummary({
    required this.totalTrends,
    required this.totalDataPoints,
    required this.averageGrowth,
    this.bestPerformingTrend,
    this.worstPerformingTrend,
    required this.positiveTrendsCount,
    required this.negativeTrendsCount,
    required this.stableTrendsCount,
    required this.categoryDistribution,
    required this.categoryCounts,
  });

  factory OverallAnalyticsSummary.empty() => const OverallAnalyticsSummary(
        totalTrends: 0,
        totalDataPoints: 0,
        averageGrowth: 0.0,
        bestPerformingTrend: null,
        worstPerformingTrend: null,
        positiveTrendsCount: 0,
        negativeTrendsCount: 0,
        stableTrendsCount: 0,
        categoryDistribution: {},
        categoryCounts: {},
      );
}

abstract class AnalyticsService {
  OverallAnalyticsSummary computeOverallSummary(List<TrendModel> trends);
}

class LocalAnalyticsService implements AnalyticsService {
  @override
  OverallAnalyticsSummary computeOverallSummary(List<TrendModel> trends) {
    if (trends.isEmpty) {
      return OverallAnalyticsSummary.empty();
    }

    final activeTrends = trends.where((t) => !t.isArchived).toList();
    if (activeTrends.isEmpty) {
      return OverallAnalyticsSummary.empty();
    }

    int totalPoints = 0;
    double sumGrowth = 0.0;
    int positiveCount = 0;
    int negativeCount = 0;
    int stableCount = 0;

    TrendModel? bestTrend;
    TrendModel? worstTrend;
    double maxGrowth = -double.infinity;
    double minGrowth = double.infinity;

    final Map<String, double> catSum = {};
    final Map<String, int> catCounts = {};

    for (final trend in activeTrends) {
      totalPoints += trend.dataPoints.length;
      final growth = trend.percentageGrowth;
      sumGrowth += growth;

      switch (trend.direction) {
        case TrendDirection.positive:
          positiveCount++;
          break;
        case TrendDirection.negative:
          negativeCount++;
          break;
        case TrendDirection.stable:
          stableCount++;
          break;
      }

      if (growth > maxGrowth) {
        maxGrowth = growth;
        bestTrend = trend;
      }
      if (growth < minGrowth) {
        minGrowth = growth;
        worstTrend = trend;
      }

      catCounts[trend.category] = (catCounts[trend.category] ?? 0) + 1;
      catSum[trend.category] = (catSum[trend.category] ?? 0) + trend.currentValue;
    }

    final avgGrowth = sumGrowth / activeTrends.length;

    return OverallAnalyticsSummary(
      totalTrends: activeTrends.length,
      totalDataPoints: totalPoints,
      averageGrowth: avgGrowth,
      bestPerformingTrend: bestTrend,
      worstPerformingTrend: worstTrend,
      positiveTrendsCount: positiveCount,
      negativeTrendsCount: negativeCount,
      stableTrendsCount: stableCount,
      categoryDistribution: catSum,
      categoryCounts: catCounts,
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:trend_curve/core/utils/growth_calculator.dart';

void main() {
  group('GrowthCalculator Tests', () {
    test('calculateGrowth handles normal positive and negative growth', () {
      // 100 -> 120 = +20%
      expect(GrowthCalculator.calculateGrowth(120, 100), closeTo(20.0, 0.001));

      // 100 -> 80 = -20%
      expect(GrowthCalculator.calculateGrowth(80, 100), closeTo(-20.0, 0.001));

      // No change = 0%
      expect(GrowthCalculator.calculateGrowth(50, 50), closeTo(0.0, 0.001));
    });

    test('calculateGrowth handles zero previous value safely without NaN or Infinity', () {
      // 0 -> 100 = 100%
      expect(GrowthCalculator.calculateGrowth(100, 0), equals(100.0));

      // 0 -> 0 = 0%
      expect(GrowthCalculator.calculateGrowth(0, 0), equals(0.0));

      // 0 -> -50 = -100%
      expect(GrowthCalculator.calculateGrowth(-50, 0), equals(-100.0));
    });

    test('determineDirection categorizes correctly based on threshold', () {
      expect(GrowthCalculator.determineDirection(5.4), equals(TrendDirection.positive));
      expect(GrowthCalculator.determineDirection(-3.2), equals(TrendDirection.negative));
      expect(GrowthCalculator.determineDirection(0.004), equals(TrendDirection.stable));
      expect(GrowthCalculator.determineDirection(-0.002), equals(TrendDirection.stable));
    });

    test('computeStats calculates accurate summary metrics and automated insight', () {
      final now = DateTime.now();
      final entries = [
        MapEntry(now.subtract(const Duration(days: 30)), 100.0),
        MapEntry(now.subtract(const Duration(days: 20)), 120.0),
        MapEntry(now.subtract(const Duration(days: 10)), 110.0),
        MapEntry(now, 150.0),
      ];

      final stats = GrowthCalculator.computeStats(
        sortedEntries: entries,
        trendName: 'Revenue',
        unit: '₹',
      );

      expect(stats.startingValue, equals(100.0));
      expect(stats.currentValue, equals(150.0));
      expect(stats.highestValue, equals(150.0));
      expect(stats.lowestValue, equals(100.0));
      expect(stats.averageValue, equals(120.0));
      expect(stats.totalChange, equals(50.0));
      expect(stats.growthPercentage, closeTo(50.0, 0.001));
      expect(stats.direction, equals(TrendDirection.positive));
      expect(stats.insightMessage, contains('increased'));
    });
  });
}

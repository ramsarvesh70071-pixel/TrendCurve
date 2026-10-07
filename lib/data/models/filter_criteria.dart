import 'package:flutter/material.dart';
import '../../core/utils/growth_calculator.dart';

/// Filtering parameters for Trends management and analytics.
class FilterCriteria {
  final String? category;
  final DateTimeRange? dateRange;
  final TrendDirection? direction;
  final String? frequency;
  final double? minValue;
  final double? maxValue;

  const FilterCriteria({
    this.category,
    this.dateRange,
    this.direction,
    this.frequency,
    this.minValue,
    this.maxValue,
  });

  bool get isEmpty =>
      category == null &&
      dateRange == null &&
      direction == null &&
      frequency == null &&
      minValue == null &&
      maxValue == null;

  FilterCriteria copyWith({
    String? category,
    DateTimeRange? dateRange,
    TrendDirection? direction,
    String? frequency,
    double? minValue,
    double? maxValue,
    bool clearCategory = false,
    bool clearDateRange = false,
    bool clearDirection = false,
    bool clearFrequency = false,
    bool clearValues = false,
  }) =>
      FilterCriteria(
        category: clearCategory ? null : (category ?? this.category),
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
        direction: clearDirection ? null : (direction ?? this.direction),
        frequency: clearFrequency ? null : (frequency ?? this.frequency),
        minValue: clearValues ? null : (minValue ?? this.minValue),
        maxValue: clearValues ? null : (maxValue ?? this.maxValue),
      );

  static const FilterCriteria empty = FilterCriteria();
}

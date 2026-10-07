import 'dart:ui';
import '../../core/utils/growth_calculator.dart';
import 'trend_data_point_model.dart';

/// Comprehensive Trend entity with full metrics calculation.
class TrendModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String unit;
  final double currentValue;
  final double previousValue;
  final double targetValue;
  final DateTime startDate;
  final String frequency;
  final String iconName;
  final String colorHex;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TrendDataPointModel> dataPoints;

  const TrendModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.unit,
    required this.currentValue,
    this.previousValue = 0.0,
    required this.targetValue,
    required this.startDate,
    this.frequency = 'Monthly',
    this.iconName = 'trending_up',
    this.colorHex = '#6366F1',
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.dataPoints = const [],
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF6366F1);
  }

  /// Chronologically sorted data points
  List<TrendDataPointModel> get sortedPoints {
    final copy = List<TrendDataPointModel>.from(dataPoints);
    copy.sort((a, b) => a.date.compareTo(b.date));
    return copy;
  }

  /// Percentage growth based on latest available changes
  double get percentageGrowth {
    if (dataPoints.length >= 2) {
      final sorted = sortedPoints;
      final latest = sorted.last.value;
      final prev = sorted[sorted.length - 2].value;
      return GrowthCalculator.calculateGrowth(latest, prev);
    }
    return GrowthCalculator.calculateGrowth(currentValue, previousValue);
  }

  /// Direction of the trend
  TrendDirection get direction => GrowthCalculator.determineDirection(percentageGrowth);

  /// Target completion progress (0.0 to 1.0+)
  double get targetProgress {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 2.0);
  }

  /// Full mathematical statistics engine
  CalculatedStatistics get statistics {
    final sorted = sortedPoints;
    final entries = sorted.map((p) => MapEntry(p.date, p.value)).toList();
    if (entries.isEmpty && currentValue > 0) {
      entries.add(MapEntry(startDate, currentValue));
    }
    return GrowthCalculator.computeStats(
      sortedEntries: entries,
      trendName: name,
      unit: unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'unit': unit,
        'currentValue': currentValue,
        'previousValue': previousValue,
        'targetValue': targetValue,
        'startDate': startDate.toIso8601String(),
        'frequency': frequency,
        'iconName': iconName,
        'colorHex': colorHex,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'dataPoints': dataPoints.map((p) => p.toJson()).toList(),
      };

  factory TrendModel.fromJson(Map<String, dynamic> json) => TrendModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        unit: json['unit'] as String? ?? '',
        currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
        previousValue: (json['previousValue'] as num?)?.toDouble() ?? 0.0,
        targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0.0,
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : DateTime.now(),
        frequency: json['frequency'] as String? ?? 'Monthly',
        iconName: json['iconName'] as String? ?? 'trending_up',
        colorHex: json['colorHex'] as String? ?? '#6366F1',
        isArchived: json['isArchived'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        dataPoints: (json['dataPoints'] as List<dynamic>?)
                ?.map((item) =>
                    TrendDataPointModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
      );

  TrendModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? unit,
    double? currentValue,
    double? previousValue,
    double? targetValue,
    DateTime? startDate,
    String? frequency,
    String? iconName,
    String? colorHex,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TrendDataPointModel>? dataPoints,
  }) =>
      TrendModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        unit: unit ?? this.unit,
        currentValue: currentValue ?? this.currentValue,
        previousValue: previousValue ?? this.previousValue,
        targetValue: targetValue ?? this.targetValue,
        startDate: startDate ?? this.startDate,
        frequency: frequency ?? this.frequency,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dataPoints: dataPoints ?? this.dataPoints,
      );
}

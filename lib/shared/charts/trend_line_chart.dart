import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/trend_data_point_model.dart';

class TrendLineChart extends StatelessWidget {
  final List<TrendDataPointModel> dataPoints;
  final String unit;
  final Color lineColor;
  final double height;
  final bool showGrid;
  final bool showTitles;

  const TrendLineChart({
    super.key,
    required this.dataPoints,
    this.unit = '',
    this.lineColor = AppColors.primary,
    this.height = 240.0,
    this.showGrid = true,
    this.showTitles = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dataPoints.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data points to display in this range.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ),
      );
    }

    final sorted = List<TrendDataPointModel>.from(dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].value));
    }

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (minY == maxY) {
      minY = minY == 0 ? -10 : minY * 0.9;
      maxY = maxY == 0 ? 10 : maxY * 1.1;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY = (minY - pad).clamp(0.0, double.infinity);
      maxY = maxY + pad;
    }

    final gridColor = isDark
        ? AppColors.cardBorderDark.withValues(alpha: 0.5)
        : AppColors.cardBorderLight.withValues(alpha: 0.8);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (sorted.length - 1).toDouble().clamp(1.0, double.infinity),
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: gridColor,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showTitles,
                reservedSize: 46,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      AppNumberFormatter.formatCompact(value, unit),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showTitles,
                reservedSize: 26,
                interval: (sorted.length > 5 ? (sorted.length / 4).floorToDouble() : 1),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sorted.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        AppDateFormatter.short(sorted[index].date),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => isDark ? AppColors.cardDark : AppColors.textPrimaryLight,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final date = index >= 0 && index < sorted.length
                      ? AppDateFormatter.medium(sorted[index].date)
                      : '';
                  final formattedVal = AppNumberFormatter.formatValue(spot.y, unit);
                  return LineTooltipItem(
                    '$date\n$formattedVal',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: sorted.length <= 15,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 3.5,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: isDark ? AppColors.backgroundDark : Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withValues(alpha: 0.3),
                    lineColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

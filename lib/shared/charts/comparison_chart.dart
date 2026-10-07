import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/trend_model.dart';

class ComparisonChart extends StatelessWidget {
  final List<TrendModel> trends;
  final double height;

  const ComparisonChart({
    super.key,
    required this.trends,
    this.height = 240.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (trends.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Select trends above to compare curves.',
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ),
      );
    }

    final barDatas = <LineChartBarData>[];
    double globalMaxX = 0;
    double globalMinY = double.infinity;
    double globalMaxY = -double.infinity;

    final palette = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.warning,
    ];

    for (int tIdx = 0; tIdx < trends.length; tIdx++) {
      final t = trends[tIdx];
      final color = palette[tIdx % palette.length];
      final sorted = t.sortedPoints;

      if (sorted.isEmpty) continue;

      final spots = <FlSpot>[];
      for (int i = 0; i < sorted.length; i++) {
        spots.add(FlSpot(i.toDouble(), sorted[i].value));
        if (sorted[i].value > globalMaxY) globalMaxY = sorted[i].value;
        if (sorted[i].value < globalMinY) globalMinY = sorted[i].value;
      }

      if ((sorted.length - 1).toDouble() > globalMaxX) {
        globalMaxX = (sorted.length - 1).toDouble();
      }

      barDatas.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: color,
          barWidth: 2.8,
          dotData: FlDotData(
            show: sorted.length <= 10,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 3,
              color: color,
              strokeWidth: 1.5,
              strokeColor: isDark ? AppColors.backgroundDark : Colors.white,
            ),
          ),
        ),
      );
    }

    if (barDatas.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Not enough data to display comparison.')),
      );
    }

    if (globalMinY == globalMaxY) {
      globalMinY = 0;
      globalMaxY = globalMaxY == 0 ? 100 : globalMaxY * 1.2;
    } else {
      final pad = (globalMaxY - globalMinY) * 0.15;
      globalMinY = (globalMinY - pad).clamp(0.0, double.infinity);
      globalMaxY += pad;
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: globalMaxX.clamp(1.0, double.infinity),
              minY: globalMinY,
              maxY: globalMaxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (globalMaxY - globalMinY) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: isDark
                      ? AppColors.cardBorderDark.withValues(alpha: 0.5)
                      : AppColors.cardBorderLight.withValues(alpha: 0.8),
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
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (val, meta) {
                      if (val == meta.min || val == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        AppNumberFormatter.formatCompact(val, ''),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      final t = trends[spot.barIndex];
                      return LineTooltipItem(
                        '${t.name}: ${AppNumberFormatter.formatValue(spot.y, t.unit)}',
                        TextStyle(
                          color: palette[spot.barIndex % palette.length],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: barDatas,
            ),
          ),
        ),
      ],
    );
  }
}

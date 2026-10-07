import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/number_formatter.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final double height;
  final Color barColor;

  const BarChartWidget({
    super.key,
    required this.data,
    this.height = 200.0,
    this.barColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No category data available.',
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ),
      );
    }

    final entries = data.entries.toList();
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < entries.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value,
              color: barColor,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxVal * 1.15,
                color: isDark
                    ? AppColors.cardBorderDark.withValues(alpha: 0.3)
                    : const Color(0xFFF1F5F9),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => isDark ? AppColors.cardDark : AppColors.textPrimaryLight,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = entries[groupIndex].key;
                final val = AppNumberFormatter.formatCompact(rod.toY, '');
                return BarTooltipItem(
                  '$label\n$val',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < entries.length) {
                    final key = entries[idx].key;
                    final shortKey = key.length > 5 ? '${key.substring(0, 4)}..' : key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        shortKey,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: groups,
        ),
      ),
    );
  }
}

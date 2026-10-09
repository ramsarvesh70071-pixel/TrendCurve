import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/trend_summary_model.dart';
import '../providers/pdf_analyzer_provider.dart';

class TrendSummaryCardsWidget extends ConsumerWidget {
  const TrendSummaryCardsWidget({super.key});

  Color _getDirectionColor(TrendDirectionType direction) {
    switch (direction) {
      case TrendDirectionType.increasing:
        return AppColors.success;
      case TrendDirectionType.decreasing:
        return AppColors.error;
      case TrendDirectionType.stable:
        return AppColors.primary;
    }
  }

  IconData _getDirectionIcon(TrendDirectionType direction) {
    switch (direction) {
      case TrendDirectionType.increasing:
        return Icons.trending_up_rounded;
      case TrendDirectionType.decreasing:
        return Icons.trending_down_rounded;
      case TrendDirectionType.stable:
        return Icons.trending_flat_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfAnalyzerProvider);
    final theme = Theme.of(context);
    final summaries = state.processedSeries.values.map((s) => s.summary).toList();

    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Statistical Trend Summary',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...summaries.map((summary) {
          final dirColor = _getDirectionColor(summary.direction);
          final dirIcon = _getDirectionIcon(summary.direction);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Variable Name & Direction Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.variableName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: dirColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(dirIcon, size: 14, color: dirColor),
                          const SizedBox(width: 5),
                          Text(
                            summary.direction.label,
                            style: TextStyle(
                              color: dirColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Metrics Grid (Min, Max, Avg, Median)
                Row(
                  children: [
                    _buildMetricBox('Average', summary.average.toStringAsFixed(2), Icons.speed_rounded, theme),
                    const SizedBox(width: 10),
                    _buildMetricBox('Median', summary.median.toStringAsFixed(2), Icons.drag_handle_rounded, theme),
                    const SizedBox(width: 10),
                    _buildMetricBox('Min', summary.min.toStringAsFixed(2), Icons.south_west_rounded, theme),
                    const SizedBox(width: 10),
                    _buildMetricBox('Max', summary.max.toStringAsFixed(2), Icons.north_east_rounded, theme),
                  ],
                ),
                const SizedBox(height: 12),

                // Change & Growth Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInlineStat('First', summary.firstValue.toStringAsFixed(2)),
                      _buildInlineStat('Last', summary.lastValue.toStringAsFixed(2)),
                      _buildInlineStat(
                        'Diff',
                        '${summary.difference >= 0 ? '+' : ''}${summary.difference.toStringAsFixed(2)}',
                        color: summary.difference >= 0 ? AppColors.success : AppColors.error,
                      ),
                      _buildInlineStat(
                        'Change',
                        '${summary.percentageChange >= 0 ? '+' : ''}${summary.percentageChange.toStringAsFixed(1)}%',
                        color: summary.percentageChange >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary.validCount} valid observations • ${summary.missingCount} missing values cleaned',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

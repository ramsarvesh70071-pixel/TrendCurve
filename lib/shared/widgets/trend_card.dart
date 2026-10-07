import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/category_model.dart';
import '../../data/models/trend_model.dart';
import '../charts/mini_trend_chart.dart';
import 'app_card.dart';
import 'percentage_indicator.dart';

class TrendCard extends StatelessWidget {
  final TrendModel trend;
  final VoidCallback onTap;

  const TrendCard({
    super.key,
    required this.trend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catInfo = CategoryModel.getByName(trend.category);
    final themeColor = trend.color;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: AppRadius.allMd,
                ),
                child: Icon(catInfo.icon, size: 22, color: themeColor),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Row(
                      children: [
                        Text(
                          trend.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (trend.targetValue > 0) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            'Goal: ${AppNumberFormatter.formatCompact(trend.targetValue, trend.unit)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              PercentageIndicator(percentage: trend.percentageGrowth),
            ],
          ),
          AppSpacing.vLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppNumberFormatter.formatValue(trend.currentValue, trend.unit),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    'Updated ${AppDateFormatter.timeAgo(trend.updatedAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              MiniTrendChart(
                dataPoints: trend.sortedPoints,
                color: themeColor,
                width: 90,
                height: 38,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

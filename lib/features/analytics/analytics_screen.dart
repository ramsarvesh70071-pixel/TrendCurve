import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/number_formatter.dart';
import '../../shared/charts/area_chart_widget.dart';
import '../../shared/charts/bar_chart_widget.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_loading_state.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= AppConstants.tabletBreakpoint;

    final trendsAsync = ref.watch(trendsProvider);
    final summary = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Analytics & Insights', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: 'Compare Trends',
            onPressed: () => context.push('/compare-trends'),
          ),
          AppSpacing.hSm,
        ],
      ),
      body: SafeArea(
        child: trendsAsync.when(
          loading: () => const AppLoadingState(message: 'Computing real-time analytics...'),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (trends) {
            final activeTrends = trends.where((t) => !t.isArchived).toList();

            if (activeTrends.isEmpty) {
              return AppEmptyState(
                icon: Icons.analytics_outlined,
                title: 'No Data for Analytics',
                subtitle: 'Create trends and log data points to compute deep growth insights.',
                actionText: 'Create a Trend',
                onAction: () => context.push('/create-trend'),
              );
            }

            final best = summary.bestPerformingTrend;
            final worst = summary.worstPerformingTrend;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- COMPARISON CTA CARD ---
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    color: isDark
                        ? AppColors.primaryContainerDark.withValues(alpha: 0.5)
                        : AppColors.primaryContainerLight,
                    border: Border.all(
                      color: isDark ? AppColors.primary : AppColors.primaryLight,
                      width: 1,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.allMd,
                          ),
                          child: const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 24),
                        ),
                        AppSpacing.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compare Multi-Trend Curves',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              AppSpacing.vXxs,
                              Text(
                                'Analyze correlations, divergence, and growth velocity',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppButton(
                          text: 'Compare',
                          height: 38,
                          onPressed: () => context.push('/compare-trends'),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vLg,

                  // --- SECTION 1: OVERVIEW METRICS ---
                  SectionHeader(title: 'Overview Metrics'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = isWide
                          ? (constraints.maxWidth - 36) / 4
                          : (constraints.maxWidth - 12) / 2;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: StatCard(
                              title: 'Average Growth',
                              value: AppNumberFormatter.formatPercentage(summary.averageGrowth),
                              growth: summary.averageGrowth,
                              icon: Icons.trending_up_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: StatCard(
                              title: 'Growing Trends',
                              value: '${summary.positiveTrendsCount} of ${summary.totalTrends}',
                              icon: Icons.arrow_upward_rounded,
                              iconColor: AppColors.success,
                              subtitle: '${((summary.positiveTrendsCount / summary.totalTrends) * 100).toStringAsFixed(0)}% healthy',
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: StatCard(
                              title: 'Declining Trends',
                              value: '${summary.negativeTrendsCount}',
                              icon: Icons.arrow_downward_rounded,
                              iconColor: AppColors.danger,
                              subtitle: 'Needs attention',
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: StatCard(
                              title: 'Stable Trends',
                              value: '${summary.stableTrendsCount}',
                              icon: Icons.trending_flat_rounded,
                              iconColor: AppColors.secondary,
                              subtitle: 'Consistent pace',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  AppSpacing.vLg,

                  // --- SECTION 2: TOP & BOTTOM PERFORMERS ---
                  SectionHeader(title: 'Growth Performance Breakdown'),
                  Row(
                    children: [
                      if (best != null)
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                                    AppSpacing.hXs,
                                    Text(
                                      'Top Performing',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.vSm,
                                Text(
                                  best.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                Text(
                                  '${AppNumberFormatter.formatValue(best.currentValue, best.unit)} (${AppNumberFormatter.formatPercentage(best.percentageGrowth)})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (worst != null && worst != best) ...[
                        AppSpacing.hMd,
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                                    AppSpacing.hXs,
                                    Text(
                                      'Needs Attention',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.vSm,
                                Text(
                                  worst.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                Text(
                                  '${AppNumberFormatter.formatValue(worst.currentValue, worst.unit)} (${AppNumberFormatter.formatPercentage(worst.percentageGrowth)})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.vLg,

                  // --- SECTION 3: CATEGORY DISTRIBUTION BAR CHART ---
                  SectionHeader(title: 'Value by Category'),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cumulative Volume Distribution',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        AppSpacing.vLg,
                        BarChartWidget(
                          data: summary.categoryDistribution,
                          height: 190,
                          barColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vLg,

                  // --- SECTION 4: AREA GROWTH TRENDS ---
                  if (best != null && best.dataPoints.isNotEmpty) ...[
                    SectionHeader(title: '${best.name} Curve Area'),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Historical Progression Area',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                'Target: ${AppNumberFormatter.formatCompact(best.targetValue, best.unit)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vLg,
                          AreaChartWidget(
                            dataPoints: best.sortedPoints,
                            unit: best.unit,
                            primaryColor: best.color,
                            height: 200,
                          ),
                        ],
                      ),
                    ),
                  ],
                  AppSpacing.vGiant,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

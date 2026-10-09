import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/trend_data_point_model.dart';
import '../../data/models/trend_model.dart';
import '../../shared/charts/trend_line_chart.dart';
import '../../shared/widgets/activity_tile.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/app_loading_state.dart';
import '../../shared/widgets/date_range_selector.dart';
import '../../shared/widgets/profile_avatar.dart';
import '../../shared/widgets/quick_action_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/trend_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedTimeRange = '30D';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<TrendDataPointModel> _getAggregatedPerformancePoints(
      List<TrendModel> trends, String range) {
    if (trends.isEmpty) return [];

    final activeTrends = trends.where((t) => !t.isArchived).toList();
    if (activeTrends.isEmpty) return [];

    // Find the best trend or aggregate points
    final best = activeTrends.reduce(
        (a, b) => a.percentageGrowth > b.percentageGrowth ? a : b);

    final sorted = best.sortedPoints;
    if (sorted.isEmpty) return [];

    final now = DateTime.now();
    Duration duration;
    switch (range) {
      case '7D':
        duration = const Duration(days: 7);
        break;
      case '30D':
        duration = const Duration(days: 30);
        break;
      case '3M':
        duration = const Duration(days: 90);
        break;
      case '6M':
        duration = const Duration(days: 180);
        break;
      case '1Y':
        duration = const Duration(days: 365);
        break;
      default:
        duration = const Duration(days: 3650);
        break;
    }

    final cutoff = now.subtract(duration);
    final filtered = sorted.where((p) => p.date.isAfter(cutoff)).toList();
    return filtered.isNotEmpty ? filtered : sorted;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= AppConstants.tabletBreakpoint;

    final trendsAsync = ref.watch(trendsProvider);
    final authState = ref.watch(authStateProvider);
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider);
    final activities = ref.watch(activityProvider);
    final summary = ref.watch(analyticsSummaryProvider);

    final userName = authState.user?.name ?? 'Alex';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: trendsAsync.when(
          loading: () => const AppLoadingState(message: 'Loading your metrics...'),
          error: (err, _) => Center(
            child: Text('Error: $err', style: const TextStyle(color: AppColors.danger)),
          ),
          data: (trends) {
            final activeTrends = trends.where((t) => !t.isArchived).toList();

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(trendsProvider.notifier).loadTrends();
                await ref.read(activityProvider.notifier).loadActivities();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ProfileAvatar(
                              name: userName,
                              size: 44,
                              onTap: () => context.go('/profile'),
                            ),
                            AppSpacing.hMd,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            AppIconButton(
                              icon: Icons.search_rounded,
                              tooltip: 'Global Search',
                              onPressed: () => context.push('/search'),
                            ),
                            AppSpacing.hSm,
                            Stack(
                              children: [
                                AppIconButton(
                                  icon: Icons.notifications_none_rounded,
                                  tooltip: 'Notifications',
                                  onPressed: () => context.push('/notifications'),
                                ),
                                if (unreadNotifs > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 8,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.vLg,
                    // --- PDF TO TREND CURVE & EXCEL ANALYZER HERO BANNER ---
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            Color(0xFF6366F1),
                            AppColors.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PDF Trend & Excel Analyzer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      'Extract variables • Plot Curves • Multi-sheet XLSX',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Upload any PDF with sensor data, financial reports, or metrics. Automatically detect columns, generate interactive curves, and export to Excel.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/pdf-analyzer'),
                              icon: const Icon(Icons.auto_graph_rounded, size: 18),
                              label: const Text(
                                'Open PDF Analyzer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vLg,

                    if (activeTrends.isEmpty) ...[
                      AppEmptyState(
                        icon: Icons.insights_rounded,
                        title: 'Start tracking your first trend.',
                        subtitle:
                            'Track business revenue, study hours, habits, or fitness metrics with real-time growth curves.',
                        actionText: AppStrings.createTrend,
                        actionIcon: Icons.add_rounded,
                        onAction: () => context.push('/create-trend'),
                      ),
                    ] else ...[
                      // --- A. OVERVIEW CARDS ---
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
                                  title: 'Total Trends',
                                  value: '${summary.totalTrends}',
                                  icon: Icons.layers_rounded,
                                  iconColor: AppColors.primary,
                                  subtitle: '${summary.positiveTrendsCount} growing',
                                  onTap: () => context.go('/trends'),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: StatCard(
                                  title: 'Data Points',
                                  value: '${summary.totalDataPoints}',
                                  icon: Icons.timeline_rounded,
                                  iconColor: AppColors.secondary,
                                  subtitle: 'Logged entries',
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: StatCard(
                                  title: 'Average Growth',
                                  value: AppNumberFormatter.formatPercentage(
                                      summary.averageGrowth),
                                  growth: summary.averageGrowth,
                                  icon: Icons.trending_up_rounded,
                                  iconColor: AppColors.success,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: StatCard(
                                  title: 'Best Performer',
                                  value: summary.bestPerformingTrend?.name ?? 'None',
                                  growth: summary.bestPerformingTrend?.percentageGrowth,
                                  icon: Icons.emoji_events_rounded,
                                  iconColor: AppColors.warning,
                                  subtitle: summary.bestPerformingTrend != null
                                      ? AppNumberFormatter.formatValue(
                                          summary.bestPerformingTrend!.currentValue,
                                          summary.bestPerformingTrend!.unit,
                                        )
                                      : null,
                                  onTap: () {
                                    if (summary.bestPerformingTrend != null) {
                                      context.push(
                                          '/trend-details/${summary.bestPerformingTrend!.id}');
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      AppSpacing.vXl,

                      // --- B. MAIN CHART SECTION ---
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.overallPerformance,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    if (summary.bestPerformingTrend != null) ...[
                                      AppSpacing.vXxs,
                                      Text(
                                        'Leading: ${summary.bestPerformingTrend!.name}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                DateRangeSelector(
                                  selectedRange: _selectedTimeRange,
                                  onSelected: (val) =>
                                      setState(() => _selectedTimeRange = val),
                                ),
                              ],
                            ),
                            AppSpacing.vLg,
                            TrendLineChart(
                              dataPoints: _getAggregatedPerformancePoints(
                                  activeTrends, _selectedTimeRange),
                              unit: summary.bestPerformingTrend?.unit ?? '',
                              lineColor: summary.bestPerformingTrend?.color ??
                                  AppColors.primary,
                              height: 220,
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.vXl,

                      // --- E. QUICK ACTIONS ---
                      SectionHeader(title: AppStrings.quickActions),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final actionWidth = isWide
                              ? (constraints.maxWidth - 36) / 4
                              : (constraints.maxWidth - 12) / 2;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: actionWidth,
                                child: QuickActionCard(
                                  icon: Icons.add_circle_outline_rounded,
                                  label: 'Create Trend',
                                  color: AppColors.primary,
                                  onTap: () => context.push('/create-trend'),
                                ),
                              ),
                              SizedBox(
                                width: actionWidth,
                                child: QuickActionCard(
                                  icon: Icons.add_chart_rounded,
                                  label: 'Add Data',
                                  color: AppColors.secondary,
                                  onTap: () {
                                    if (activeTrends.isNotEmpty) {
                                      context.push(
                                          '/add-data-point/${activeTrends.first.id}');
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: actionWidth,
                                child: QuickActionCard(
                                  icon: Icons.compare_arrows_rounded,
                                  label: 'Compare',
                                  color: AppColors.tertiary,
                                  onTap: () => context.push('/compare-trends'),
                                ),
                              ),
                              SizedBox(
                                width: actionWidth,
                                child: QuickActionCard(
                                  icon: Icons.analytics_rounded,
                                  label: 'View Analytics',
                                  color: AppColors.warning,
                                  onTap: () => context.go('/analytics'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      AppSpacing.vXl,

                      // --- C. RECENT TRENDS ---
                      SectionHeader(
                        title: AppStrings.recentTrends,
                        actionText: 'See All (${activeTrends.length})',
                        onAction: () => context.go('/trends'),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeTrends.take(3).length,
                        separatorBuilder: (_, __) => AppSpacing.vMd,
                        itemBuilder: (context, index) {
                          final trend = activeTrends[index];
                          return TrendCard(
                            trend: trend,
                            onTap: () =>
                                context.push('/trend-details/${trend.id}'),
                          );
                        },
                      ),
                      AppSpacing.vXl,

                      // --- D. RECENT ACTIVITY ---
                      SectionHeader(
                        title: AppStrings.recentActivity,
                        actionText: 'View All',
                        onAction: () => context.go('/activity'),
                      ),
                      if (activities.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Text(
                              'No recent activity recorded yet.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activities.take(3).length,
                          separatorBuilder: (_, __) => AppSpacing.vSm,
                          itemBuilder: (context, index) {
                            return ActivityTile(activity: activities[index]);
                          },
                        ),
                      AppSpacing.vGiant,
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

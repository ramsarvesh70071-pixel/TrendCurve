import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/trend_data_point_model.dart';
import '../../shared/charts/trend_line_chart.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/date_range_selector.dart';
import '../../shared/widgets/percentage_indicator.dart';
import '../../shared/widgets/section_header.dart';
import 'add_data_point_dialog.dart';
import 'edit_data_point_dialog.dart';

class TrendDetailsScreen extends ConsumerStatefulWidget {
  final String trendId;

  const TrendDetailsScreen({super.key, required this.trendId});

  @override
  ConsumerState<TrendDetailsScreen> createState() => _TrendDetailsScreenState();
}

class _TrendDetailsScreenState extends ConsumerState<TrendDetailsScreen> {
  String _selectedTimeRange = 'All';

  List<TrendDataPointModel> _filterPointsByRange(
      List<TrendDataPointModel> points, String range) {
    if (points.isEmpty) return [];
    if (range == 'All') return points;

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
    final filtered = points.where((p) => p.date.isAfter(cutoff)).toList();
    return filtered.isNotEmpty ? filtered : points;
  }

  void _handleDelete() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Trend',
      message: 'Are you sure you want to delete this trend? All associated data points will be permanently deleted.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(trendsProvider.notifier).deleteTrend(widget.trendId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trend deleted successfully.')),
      );
      context.pop();
    }
  }

  void _handleDuplicate() async {
    final dup = await ref.read(trendsProvider.notifier).duplicateTrend(widget.trendId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created duplicate "${dup.name}"')),
    );
    context.push('/trend-details/${dup.id}');
  }

  void _handleToggleArchive() async {
    final toggled = await ref.read(trendsProvider.notifier).toggleArchive(widget.trendId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(toggled.isArchived ? 'Trend archived.' : 'Trend restored from archive.'),
      ),
    );
  }

  void _deleteDataPoint(String pointId) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Data Point',
      message: 'Are you sure you want to delete this historical data entry?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(trendsProvider.notifier).deleteDataPoint(widget.trendId, pointId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data point removed. Chart recalculated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= AppConstants.tabletBreakpoint;

    final trend = ref.watch(trendDetailsProvider(widget.trendId));

    if (trend == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trend Details')),
        body: Center(
          child: AppEmptyState(
            title: 'Trend not found',
            subtitle: 'This trend might have been deleted or archived.',
            actionText: 'Return to Trends',
            onAction: () => context.go('/trends'),
          ),
        ),
      );
    }

    final stats = trend.statistics;
    final points = trend.sortedPoints;
    final displayedPoints = _filterPointsByRange(points, _selectedTimeRange);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trend.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              trend.category,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
            onSelected: (val) {
              switch (val) {
                case 'edit':
                  context.push('/edit-trend/${trend.id}');
                  break;
                case 'duplicate':
                  _handleDuplicate();
                  break;
                case 'archive':
                  _handleToggleArchive();
                  break;
                case 'delete':
                  _handleDelete();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Trend'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(trend.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(trend.isArchived ? 'Restore' : 'Archive'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.hSm,
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP SUMMARY HEADER ---
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Value',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              AppNumberFormatter.formatValue(trend.currentValue, trend.unit),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        PercentageIndicator(
                          percentage: trend.percentageGrowth,
                          fontSize: 14,
                        ),
                      ],
                    ),
                    AppSpacing.vMd,
                    // Automated Insight Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: trend.color.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: AppRadius.allMd,
                        border: Border.all(
                          color: trend.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 18, color: trend.color),
                          AppSpacing.hSm,
                          Expanded(
                            child: Text(
                              stats.insightMessage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vLg,

              // --- LARGE INTERACTIVE CHART ---
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Performance Curve',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
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
                      dataPoints: displayedPoints,
                      unit: trend.unit,
                      lineColor: trend.color,
                      height: 250,
                    ),
                  ],
                ),
              ),
              AppSpacing.vLg,

              // --- STATISTICS GRID ---
              SectionHeader(title: 'Calculated Statistics'),
              LayoutBuilder(
                builder: (context, constraints) {
                  final statWidth = isWide
                      ? (constraints.maxWidth - 36) / 4
                      : (constraints.maxWidth - 12) / 2;

                  Widget miniStat(String title, String val, {Color? valueColor}) {
                    return SizedBox(
                      width: statWidth,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              val,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: valueColor ??
                                    (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      miniStat('Starting Value', AppNumberFormatter.formatValue(stats.startingValue, trend.unit)),
                      miniStat('Highest Point', AppNumberFormatter.formatValue(stats.highestValue, trend.unit), valueColor: AppColors.success),
                      miniStat('Lowest Point', AppNumberFormatter.formatValue(stats.lowestValue, trend.unit), valueColor: AppColors.danger),
                      miniStat('Average Value', AppNumberFormatter.formatValue(stats.averageValue, trend.unit)),
                      miniStat('Total Change', '${stats.totalChange >= 0 ? "+" : ""}${AppNumberFormatter.formatValue(stats.totalChange, trend.unit)}'),
                      miniStat('Overall Growth', AppNumberFormatter.formatPercentage(stats.growthPercentage)),
                      miniStat('Best Spike', stats.bestPeriodLabel ?? 'N/A'),
                      miniStat('Target Goal', AppNumberFormatter.formatValue(trend.targetValue, trend.unit)),
                    ],
                  );
                },
              ),
              AppSpacing.vLg,

              // --- DATA POINTS LIST ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(title: 'Recorded Data Points (${points.length})'),
                  AppButton(
                    text: 'Add Point',
                    icon: Icons.add_rounded,
                    height: 38,
                    onPressed: () => AddDataPointDialog.show(context, trend.id),
                  ),
                ],
              ),
              if (points.isEmpty) ...[
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.add_chart_rounded, size: 36, color: AppColors.primary),
                        AppSpacing.vMd,
                        const Text(
                          'No historical data points yet.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        AppSpacing.vSm,
                        AppButton(
                          text: 'Log First Data Point',
                          variant: AppButtonVariant.primary,
                          onPressed: () => AddDataPointDialog.show(context, trend.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: points.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (context, index) {
                    // Show in reverse chronological order (latest on top)
                    final pt = points[points.length - 1 - index];
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: trend.color.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: AppRadius.allMd,
                            ),
                            child: Icon(Icons.calendar_today_rounded, size: 16, color: trend.color),
                          ),
                          AppSpacing.hMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppNumberFormatter.formatValue(pt.value, trend.unit),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                Row(
                                  children: [
                                    Text(
                                      AppDateFormatter.medium(pt.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    if (pt.note != null && pt.note!.isNotEmpty) ...[
                                      Text(
                                        ' • ',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMutedLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          pt.note!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIconButton(
                                icon: Icons.edit_outlined,
                                size: 34,
                                iconSize: 16,
                                tooltip: 'Edit',
                                onPressed: () =>
                                    EditDataPointDialog.show(context, trend.id, pt),
                              ),
                              AppSpacing.hXs,
                              AppIconButton(
                                icon: Icons.delete_outline_rounded,
                                size: 34,
                                iconSize: 16,
                                color: AppColors.danger,
                                tooltip: 'Delete',
                                onPressed: () => _deleteDataPoint(pt.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              AppSpacing.vGiant,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Point', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => AddDataPointDialog.show(context, trend.id),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/number_formatter.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_icon_button.dart';
import 'add_data_point_dialog.dart';
import 'edit_data_point_dialog.dart';

class AllDataPointsScreen extends ConsumerWidget {
  final String trendId;

  const AllDataPointsScreen({super.key, required this.trendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trend = ref.watch(trendDetailsProvider(trendId));

    if (trend == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.allDataPoints)),
        body: const Center(child: Text('Trend not found')),
      );
    }

    final points = trend.sortedPoints.reversed.toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('${trend.name} Points', style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Data Point',
            onPressed: () => AddDataPointDialog.show(context, trend.id),
          ),
          AppSpacing.hSm,
        ],
      ),
      body: points.isEmpty
          ? AppEmptyState(
              title: 'No Data Points',
              subtitle: 'Add entries to visualize history for this trend.',
              actionText: 'Add Data Point',
              onAction: () => AddDataPointDialog.show(context, trend.id),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: points.length,
              separatorBuilder: (_, __) => AppSpacing.vSm,
              itemBuilder: (context, index) {
                final pt = points[index];
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
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
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                                    ' • ${pt.note!}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
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
                            onPressed: () =>
                                EditDataPointDialog.show(context, trend.id, pt),
                          ),
                          AppSpacing.hXs,
                          AppIconButton(
                            icon: Icons.delete_outline_rounded,
                            size: 34,
                            iconSize: 16,
                            color: AppColors.danger,
                            onPressed: () async {
                              final confirmed = await AppDialog.showConfirmation(
                                context: context,
                                title: 'Delete Point',
                                message: 'Delete this data point entry?',
                                isDestructive: true,
                              );
                              if (confirmed == true) {
                                await ref
                                    .read(trendsProvider.notifier)
                                    .deleteDataPoint(trend.id, pt.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/activity_model.dart';
import 'app_card.dart';

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onTap;

  const ActivityTile({
    super.key,
    required this.activity,
    this.onTap,
  });

  IconData _getIcon() {
    switch (activity.iconName) {
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'add_chart':
        return Icons.add_chart_rounded;
      case 'download':
        return Icons.download_rounded;
      case 'delete':
        return Icons.delete_outline_rounded;
      default:
        return Icons.timeline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppRadius.allMd,
            ),
            child: Icon(_getIcon(), size: 18, color: AppColors.primary),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  AppDateFormatter.timeAgo(activity.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

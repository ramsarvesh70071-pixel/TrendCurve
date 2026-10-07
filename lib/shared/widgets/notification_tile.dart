import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/notification_model.dart';
import 'app_card.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.trendMilestone:
        icon = Icons.emoji_events_rounded;
        iconColor = AppColors.warning;
        break;
      case NotificationType.goalReached:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        break;
      case NotificationType.dataReminder:
        icon = Icons.alarm_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.trendDecline:
        icon = Icons.trending_down_rounded;
        iconColor = AppColors.danger;
        break;
      case NotificationType.systemNotification:
        icon = Icons.info_rounded;
        iconColor = AppColors.secondary;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: AppRadius.allLg,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: AppCard(
        onTap: onTap,
        color: notification.isRead
            ? null
            : (isDark
                ? AppColors.primaryContainerDark.withValues(alpha: 0.3)
                : AppColors.primaryContainerLight.withValues(alpha: 0.5)),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: AppRadius.allMd,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        AppSpacing.hSm,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.vXs,
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.35,
                    ),
                  ),
                  AppSpacing.vSm,
                  Text(
                    AppDateFormatter.timeAgo(notification.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

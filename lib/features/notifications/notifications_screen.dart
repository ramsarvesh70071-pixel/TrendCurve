import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('Mark all as read', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          AppSpacing.hSm,
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No Notifications',
                subtitle: "You're all caught up! Milestones and reminders will appear here.",
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => AppSpacing.vSm,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return NotificationTile(
                    notification: notif,
                    onTap: () {
                      if (!notif.isRead) {
                        ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                      }
                      if (notif.relatedTrendId != null) {
                        context.push('/trend-details/${notif.relatedTrendId}');
                      }
                    },
                    onDelete: () {
                      ref.read(notificationsProvider.notifier).deleteNotification(notif.id);
                    },
                  );
                },
              ),
      ),
    );
  }
}

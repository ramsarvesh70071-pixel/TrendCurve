import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/activity_tile.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/search_field.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearActivities() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Clear Activity History',
      message: 'Are you sure you want to clear your timeline log history?',
      confirmText: 'Clear',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(activityProvider.notifier).clearActivities();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity history cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activities = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Activity Log', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (activities.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: _clearActivities,
            ),
          AppSpacing.hSm,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: SearchField(
                controller: _searchController,
                hint: 'Filter activity log...',
                onChanged: (q) => ref.read(activityProvider.notifier).loadActivities(query: q),
                onClear: () => ref.read(activityProvider.notifier).loadActivities(),
              ),
            ),
            Expanded(
              child: activities.isEmpty
                  ? AppEmptyState(
                      icon: Icons.history_rounded,
                      title: 'No Activity Found',
                      subtitle: 'Timeline entries will automatically log as you modify trends and data.',
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(activityProvider.notifier).loadActivities();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => AppSpacing.vSm,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return ActivityTile(
                            activity: activity,
                            onTap: activity.trendId != null
                                ? () => context.push('/trend-details/${activity.trendId}')
                                : null,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showExportDialog() {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final jsonExport = settingsRepo.exportJson();
    final csvExport = settingsRepo.exportCsv();

    showDialog(
      context: context,
      builder: (ctx) {
        return DefaultTabController(
          length: 2,
          child: AlertDialog(
            title: const Text('Export Analytics Data'),
            content: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'JSON Format'),
                      Tab(text: 'CSV Format'),
                    ],
                  ),
                  AppSpacing.vMd,
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: SelectableText(
                            jsonExport,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                        SingleChildScrollView(
                          child: SelectableText(
                            csvExport,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy to Clipboard'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonExport));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON data copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Import Backup JSON'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Paste raw Trend Curve JSON backup data below to restore trends.',
                  style: TextStyle(fontSize: 13),
                ),
                AppSpacing.vMd,
                TextField(
                  controller: controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: '{\n  "trends": [...]\n}',
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final success =
                      await ref.read(settingsRepositoryProvider).importJson(text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (success) {
                    await ref.read(trendsProvider.notifier).loadTrends();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data imported successfully!')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to import: Invalid JSON format'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  void _clearData() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Clear Local Data',
      message:
          'Are you sure you want to delete all trends, activities, and data points? This will reset the app to an empty state.',
      confirmText: 'Clear All Data',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      await ref.read(settingsRepositoryProvider).clearAllData();
      await ref.read(trendsProvider.notifier).loadTrends();
      await ref.read(activityProvider.notifier).loadActivities();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared. Showing empty state.')),
      );
    }
  }

  void _restoreSeedData() async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Reset to Sample Data',
      message: 'Restore default sample metrics (Revenue, Visitors, Study Hours, etc.)?',
      confirmText: 'Restore Data',
    );

    if (confirmed == true && mounted) {
      await ref.read(settingsRepositoryProvider).resetToSeedData();
      await ref.read(trendsProvider.notifier).loadTrends();
      await ref.read(activityProvider.notifier).loadActivities();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample metrics restored successfully!')),
      );
    }
  }

  void _changeCurrency() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('Select Default Currency / Unit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...['₹', '\$', '€', '£', '¥'].map((curr) {
                return ListTile(
                  title: Text(curr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await ref.read(settingsRepositoryProvider).setDefaultCurrency(curr);
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsRepo = ref.watch(settingsRepositoryProvider);

    final currentCurrency = settingsRepo.getDefaultCurrency();
    final currentNotifications = settingsRepo.getNotificationsEnabled();

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm, top: AppSpacing.md),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      );
    }

    Widget settingTile({
      required IconData icon,
      required String title,
      String? value,
      Widget? trailing,
      VoidCallback? onTap,
    }) {
      return ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        leading: Icon(icon, size: 22, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value != null)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                AppSpacing.hXs,
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ],
            ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ACCOUNT ---
              sectionTitle('ACCOUNT'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    settingTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () => context.push('/account-settings'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password & Security',
                      onTap: () => context.push('/security'),
                    ),
                  ],
                ),
              ),

              // --- PREFERENCES ---
              sectionTitle('PREFERENCES'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    settingTile(
                      icon: Icons.palette_outlined,
                      title: 'Theme & Appearance',
                      value: isDark ? 'Dark Mode' : 'Light Mode',
                      onTap: () => context.push('/appearance'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Push Alerts & Reminders',
                      trailing: Switch(
                        value: currentNotifications,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) async {
                          await settingsRepo.setNotificationsEnabled(val);
                          setState(() {});
                        },
                      ),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.currency_rupee_rounded,
                      title: 'Default Currency / Unit',
                      value: currentCurrency,
                      onTap: _changeCurrency,
                    ),
                  ],
                ),
              ),

              // --- DATA MANAGEMENT ---
              sectionTitle('DATA & BACKUP'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    settingTile(
                      icon: Icons.file_download_outlined,
                      title: 'Export Data (JSON / CSV)',
                      onTap: _showExportDialog,
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.file_upload_outlined,
                      title: 'Import Data from Backup',
                      onTap: _showImportDialog,
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.restore_rounded,
                      title: 'Restore Default Sample Data',
                      onTap: _restoreSeedData,
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Clear All Local Data',
                      trailing: const Text(
                        'Clear',
                        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                      ),
                      onTap: _clearData,
                    ),
                  ],
                ),
              ),

              // --- ABOUT ---
              sectionTitle('ABOUT'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    settingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Trend Curve',
                      value: 'v${AppConstants.appVersion}',
                      onTap: () => context.push('/about'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.policy_outlined,
                      title: 'Privacy Policy',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => context.push('/terms'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    settingTile(
                      icon: Icons.help_center_outlined,
                      title: 'Help & Support',
                      onTap: () => context.push('/help-support'),
                    ),
                  ],
                ),
              ),
              AppSpacing.vGiant,
            ],
          ),
        ),
      ),
    );
  }
}

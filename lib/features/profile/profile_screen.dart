import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final summary = ref.watch(analyticsSummaryProvider);

    final user = authState.user;
    final name = user?.name ?? 'Alex Rivera';
    final email = user?.email ?? 'alex.rivera@trendcurve.io';

    void handleLogout() async {
      final confirmed = await AppDialog.showConfirmation(
        context: context,
        title: 'Sign Out',
        message: 'Are you sure you want to sign out from Trend Curve?',
        confirmText: 'Sign Out',
        isDestructive: true,
      );

      if (confirmed == true) {
        await ref.read(authStateProvider.notifier).logout();
        if (context.mounted) {
          context.go('/login');
        }
      }
    }

    Widget profileTile({
      required IconData icon,
      required String title,
      String? subtitle,
      Color? iconColor,
      VoidCallback? onTap,
    }) {
      return ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: AppRadius.allMd,
          ),
          child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          AppSpacing.hSm,
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // --- USER PROFILE CARD ---
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    ProfileAvatar(
                      name: name,
                      size: 80,
                    ),
                    AppSpacing.vLg,
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.vXl,
                    // Mini summary metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${summary.totalTrends}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              'Total Trends',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight,
                        ),
                        Column(
                          children: [
                            Text(
                              '${summary.totalDataPoints}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              'Data Points',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.vXl,

              // --- MENU OPTIONS ---
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    profileTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your display name and email',
                      onTap: () => context.push('/account-settings'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    profileTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Switch Light, Dark or System Theme',
                      onTap: () => context.push('/appearance'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    profileTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Manage alerts and milestones',
                      onTap: () => context.push('/notifications'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    profileTile(
                      icon: Icons.security_rounded,
                      title: 'Security',
                      subtitle: 'Password and secure credentials',
                      onTap: () => context.push('/security'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    profileTile(
                      icon: Icons.settings_outlined,
                      title: 'All Settings & Preferences',
                      subtitle: 'Currencies, backup export & import',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
              AppSpacing.vLg,

              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    profileTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () => context.push('/help-support'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    profileTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Trend Curve',
                      subtitle: 'Version ${AppConstants.appVersion}',
                      onTap: () => context.push('/about'),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight),
                    profileTile(
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      iconColor: AppColors.danger,
                      onTap: handleLogout,
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

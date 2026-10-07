import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget themeOption({
      required ThemeMode mode,
      required String title,
      required String subtitle,
      required IconData icon,
    }) {
      final isSelected = currentThemeMode == mode;
      return AppCard(
        onTap: () {
          ref.read(themeModeProvider.notifier).setTheme(mode);
        },
        padding: const EdgeInsets.all(AppSpacing.lg),
        color: isSelected
            ? (isDark
                ? AppColors.primaryContainerDark.withValues(alpha: 0.5)
                : AppColors.primaryContainerLight)
            : null,
        border: Border.all(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          width: isSelected ? 1.5 : 1,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : const Color(0xFFF1F5F9)),
                borderRadius: AppRadius.allMd,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                size: 22,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Theme & Appearance', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Application Theme',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppSpacing.vMd,
              themeOption(
                mode: ThemeMode.light,
                title: 'Light Theme',
                subtitle: 'Crisp, clean high-contrast daytime interface',
                icon: Icons.light_mode_rounded,
              ),
              AppSpacing.vMd,
              themeOption(
                mode: ThemeMode.dark,
                title: 'Dark Theme',
                subtitle: 'Deep charcoal navy curated for OLED & night analytics',
                icon: Icons.dark_mode_rounded,
              ),
              AppSpacing.vMd,
              themeOption(
                mode: ThemeMode.system,
                title: 'System Default',
                subtitle: 'Automatically syncs with your device display settings',
                icon: Icons.settings_brightness_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryThemeColor = color ?? AppColors.primary;

    final bg = isSelected
        ? primaryThemeColor.withValues(alpha: isDark ? 0.25 : 0.15)
        : (isDark ? AppColors.cardDark : const Color(0xFFF1F5F9));

    final fg = isSelected
        ? primaryThemeColor
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    final borderColor = isSelected
        ? primaryThemeColor
        : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allFull,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.allFull,
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              AppSpacing.hXs,
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

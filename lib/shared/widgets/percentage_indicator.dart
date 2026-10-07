import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/growth_calculator.dart';
import '../../core/utils/number_formatter.dart';

class PercentageIndicator extends StatelessWidget {
  final double percentage;
  final bool showBackground;
  final double fontSize;

  const PercentageIndicator({
    super.key,
    required this.percentage,
    this.showBackground = true,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final direction = GrowthCalculator.determineDirection(percentage);

    Color fg;
    Color bg;
    IconData icon;

    switch (direction) {
      case TrendDirection.positive:
        fg = AppColors.success;
        bg = isDark ? AppColors.successContainerDark : AppColors.successContainer;
        icon = Icons.trending_up_rounded;
        break;
      case TrendDirection.negative:
        fg = AppColors.danger;
        bg = isDark ? AppColors.dangerContainerDark : AppColors.dangerContainer;
        icon = Icons.trending_down_rounded;
        break;
      case TrendDirection.stable:
        fg = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        bg = isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0);
        icon = Icons.trending_flat_rounded;
        break;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: fontSize + 2, color: fg),
        AppSpacing.hXxs,
        Text(
          AppNumberFormatter.formatPercentage(percentage),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    );

    if (!showBackground) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.allFull,
      ),
      child: content,
    );
  }
}

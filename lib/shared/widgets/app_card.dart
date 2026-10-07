import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final BorderRadius? borderRadius;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.allLg;

    final cardWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.cardDark : AppColors.cardLight),
        borderRadius: radius,
        border: border ??
            Border.all(
              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
              width: 1,
            ),
        boxShadow: hasShadow ? AppShadows.subtle(isDark) : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

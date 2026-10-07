import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms & Conditions of Use',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                AppSpacing.vMd,
                Text(
                  'By installing and utilizing Trend Curve, you acknowledge and agree to the following conditions:\n\n'
                  '1. Permitted Use: Trend Curve is provided for personal and business metric observation. You agree not to misuse or attempt unauthorized disruption of the service.\n\n'
                  '2. Calculations & Analytics: Trend statistics, momentum rates, and percentage projections are computed mathematically based directly on your entered data points.\n\n'
                  '3. Backup Responsibility: As an offline-capable tool, you are encouraged to periodically utilize the built-in Export Data utility to safeguard against accidental device loss or clearance.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

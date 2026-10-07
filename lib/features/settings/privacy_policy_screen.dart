import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Data Stays on Your Device',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    AppSpacing.vMd,
                    Text(
                      'Trend Curve is designed with a local-first philosophy. All trends, data points, categories, and metrics are stored locally in secure sandboxed storage on your device.\n\n'
                      '1. Local Data Sovereignty: You maintain 100% control over your data. You can export everything as JSON or CSV at any moment.\n\n'
                      '2. No Unapproved Telemetry: We do not track your sensitive financial numbers or personal metrics without your explicit authorization.\n\n'
                      '3. Encryption: Sensitive authentication tokens are saved in platform-native secure vaults (Keychain / Keystore / DPAPI).\n\n'
                      '4. Future Cloud Sync: When connecting to our upcoming Node.js + MongoDB cloud sync, data is transmitted exclusively via TLS 1.3 encrypted REST APIs.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

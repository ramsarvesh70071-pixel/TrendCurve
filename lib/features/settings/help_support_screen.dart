import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'How is percentage growth calculated?',
      'a': 'Growth is calculated as ((currentValue - previousValue) / previousValue) * 100. When comparing against historical points, it measures between the latest entry and the preceding period entry.'
    },
    {
      'q': 'Can I track metrics with custom currency or units?',
      'a': 'Yes! You can specify any custom unit or symbol (e.g. ₹, \$, €, kg, hours, visitors, pts) when creating or editing a trend.'
    },
    {
      'q': 'How do I compare two or more trends on one chart?',
      'a': 'Navigate to Analytics > Compare Trends or tap the Compare button in the Quick Actions section on your Dashboard. You can select up to 3 trends simultaneously.'
    },
    {
      'q': 'How do I backup my data?',
      'a': 'Go to Settings > Export Data. You can preview and copy your entire database formatted as JSON or CSV.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w800)),
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
                  children: [
                    const Icon(Icons.support_agent_rounded, size: 44, color: AppColors.primary),
                    AppSpacing.vMd,
                    const Text(
                      'How can we help you?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.vXs,
                    Text(
                      'Have questions or need assistance with your data tracking?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    AppSpacing.vLg,
                    AppButton(
                      text: 'Contact Support Team',
                      icon: Icons.mail_outline_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Support request logged. We will reach back via email!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.vXl,
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              AppSpacing.vMd,
              ..._faqs.map(
                (faq) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: ExpansionTile(
                      shape: const Border(),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 8),
                      title: Text(
                        faq['q']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      children: [
                        Text(
                          faq['a']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

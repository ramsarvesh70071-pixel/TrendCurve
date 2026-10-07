import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_text_field.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _biometricsEnabled = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Security & Password', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 28, color: AppColors.primary),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biometric Unlock',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            'Unlock Trend Curve using Face ID or Fingerprint',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _biometricsEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _biometricsEnabled = val),
                    ),
                  ],
                ),
              ),
              AppSpacing.vXl,
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              AppSpacing.vMd,
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Current Password',
                        controller: _currentPassController,
                        obscureText: true,
                        validator: AppValidators.password,
                      ),
                      AppSpacing.vMd,
                      AppTextField(
                        label: 'New Password',
                        controller: _newPassController,
                        obscureText: true,
                        validator: AppValidators.password,
                      ),
                      AppSpacing.vMd,
                      AppTextField(
                        label: 'Confirm New Password',
                        controller: _confirmPassController,
                        obscureText: true,
                        validator: (v) =>
                            AppValidators.confirmPassword(v, _newPassController.text),
                      ),
                      AppSpacing.vXl,
                      AppButton(
                        text: 'Update Password',
                        isLoading: _isLoading,
                        width: double.infinity,
                        onPressed: _handleChangePassword,
                      ),
                    ],
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

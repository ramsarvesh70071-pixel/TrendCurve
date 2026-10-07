import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/trend_data_point_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

class EditDataPointDialog extends ConsumerStatefulWidget {
  final String trendId;
  final TrendDataPointModel dataPoint;

  const EditDataPointDialog({
    super.key,
    required this.trendId,
    required this.dataPoint,
  });

  static Future<bool?> show(
    BuildContext context,
    String trendId,
    TrendDataPointModel dataPoint,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => EditDataPointDialog(
        trendId: trendId,
        dataPoint: dataPoint,
      ),
    );
  }

  @override
  ConsumerState<EditDataPointDialog> createState() => _EditDataPointDialogState();
}

class _EditDataPointDialogState extends ConsumerState<EditDataPointDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  late TextEditingController _noteController;
  late DateTime _date;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.dataPoint.value.toString());
    _noteController = TextEditingController(text: widget.dataPoint.note ?? '');
    _date = widget.dataPoint.date;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final val = double.parse(_valueController.text.trim().replaceAll(',', ''));
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    final updatedPoint = widget.dataPoint.copyWith(
      date: _date,
      value: val,
      note: note,
    );

    try {
      await ref
          .read(trendsProvider.notifier)
          .updateDataPoint(widget.trendId, updatedPoint);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data point updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trend = ref.watch(trendDetailsProvider(widget.trendId));

    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.allXl),
      title: Text(
        'Edit Data Point',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Date *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppSpacing.vXs,
              InkWell(
                onTap: _pickDate,
                borderRadius: AppRadius.allMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: AppRadius.allMd,
                    border: Border.all(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppDateFormatter.medium(_date),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              AppSpacing.vLg,
              AppTextField(
                label: 'Value (${trend?.unit ?? ""}) *',
                controller: _valueController,
                keyboardType: TextInputType.number,
                validator: AppValidators.number,
              ),
              AppSpacing.vLg,
              AppTextField(
                label: 'Note',
                controller: _noteController,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              text: 'Cancel',
              variant: AppButtonVariant.outline,
              height: 42,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppSpacing.hSm,
            AppButton(
              text: 'Save',
              height: 42,
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/growth_calculator.dart';
import '../../data/models/filter_criteria.dart';
import 'app_button.dart';
import 'app_chip.dart';
import 'app_text_field.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterCriteria initialCriteria;
  final ValueChanged<FilterCriteria> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategory;
  late TrendDirection? _selectedDirection;
  late String? _selectedFrequency;
  late TextEditingController _minValController;
  late TextEditingController _maxValController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCriteria.category;
    _selectedDirection = widget.initialCriteria.direction;
    _selectedFrequency = widget.initialCriteria.frequency;
    _minValController = TextEditingController(
      text: widget.initialCriteria.minValue != null
          ? widget.initialCriteria.minValue!.toStringAsFixed(0)
          : '',
    );
    _maxValController = TextEditingController(
      text: widget.initialCriteria.maxValue != null
          ? widget.initialCriteria.maxValue!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _minValController.dispose();
    _maxValController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _selectedDirection = null;
      _selectedFrequency = null;
      _minValController.clear();
      _maxValController.clear();
    });
    widget.onApply(FilterCriteria.empty);
    Navigator.of(context).pop();
  }

  void _apply() {
    final min = double.tryParse(_minValController.text.trim());
    final max = double.tryParse(_maxValController.text.trim());

    final criteria = FilterCriteria(
      category: _selectedCategory,
      direction: _selectedDirection,
      frequency: _selectedFrequency,
      minValue: min,
      maxValue: max,
    );

    widget.onApply(criteria);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.vSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return AppChip(
                label: cat,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = isSelected ? null : cat;
                  });
                },
              );
            }).toList(),
          ),
          AppSpacing.vLg,
          Text(
            'Trend Direction',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.vSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(
                label: 'Positive Growth',
                icon: Icons.trending_up_rounded,
                isSelected: _selectedDirection == TrendDirection.positive,
                color: AppColors.success,
                onTap: () {
                  setState(() {
                    _selectedDirection =
                        _selectedDirection == TrendDirection.positive
                            ? null
                            : TrendDirection.positive;
                  });
                },
              ),
              AppChip(
                label: 'Negative Decline',
                icon: Icons.trending_down_rounded,
                isSelected: _selectedDirection == TrendDirection.negative,
                color: AppColors.danger,
                onTap: () {
                  setState(() {
                    _selectedDirection =
                        _selectedDirection == TrendDirection.negative
                            ? null
                            : TrendDirection.negative;
                  });
                },
              ),
              AppChip(
                label: 'Stable',
                icon: Icons.trending_flat_rounded,
                isSelected: _selectedDirection == TrendDirection.stable,
                color: AppColors.secondary,
                onTap: () {
                  setState(() {
                    _selectedDirection =
                        _selectedDirection == TrendDirection.stable
                            ? null
                            : TrendDirection.stable;
                  });
                },
              ),
            ],
          ),
          AppSpacing.vLg,
          Text(
            'Frequency',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.vSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.frequencies.map((freq) {
              final isSelected = _selectedFrequency == freq;
              return AppChip(
                label: freq,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedFrequency = isSelected ? null : freq;
                  });
                },
              );
            }).toList(),
          ),
          AppSpacing.vLg,
          Text(
            'Value Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _minValController,
                  hint: 'Min Value',
                  keyboardType: TextInputType.number,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppTextField(
                  controller: _maxValController,
                  hint: 'Max Value',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          AppSpacing.vXxl,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Reset',
                  variant: AppButtonVariant.outline,
                  onPressed: _reset,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppButton(
                  text: 'Apply Filters',
                  variant: AppButtonVariant.primary,
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

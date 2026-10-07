import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/category_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/app_error_state.dart';
import '../../shared/widgets/app_text_field.dart';

class EditTrendScreen extends ConsumerStatefulWidget {
  final String trendId;

  const EditTrendScreen({super.key, required this.trendId});

  @override
  ConsumerState<EditTrendScreen> createState() => _EditTrendScreenState();
}

class _EditTrendScreenState extends ConsumerState<EditTrendScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  late TextEditingController _targetValueController;

  late String _selectedCategory;
  late String _selectedFrequency;
  late DateTime _startDate;
  late Color _selectedColor;
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<Color> _availableColors = [
    const Color(0xFF6366F1),
    const Color(0xFF06B6D4),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF3B82F6),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final trend = ref.read(trendDetailsProvider(widget.trendId));
      if (trend != null) {
        _nameController = TextEditingController(text: trend.name);
        _descriptionController = TextEditingController(text: trend.description);
        _unitController = TextEditingController(text: trend.unit);
        _targetValueController =
            TextEditingController(text: trend.targetValue.toStringAsFixed(0));
        _selectedCategory = trend.category;
        _selectedFrequency = trend.frequency;
        _startDate = trend.startDate;
        _selectedColor = trend.color;
        _isInitialized = true;
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _nameController.dispose();
      _descriptionController.dispose();
      _unitController.dispose();
      _targetValueController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final trend = ref.read(trendDetailsProvider(widget.trendId));
    if (trend == null) return;

    final targetVal = double.tryParse(_targetValueController.text.trim()) ?? 0.0;
    final colorHex = '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}';

    final updated = trend.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      unit: _unitController.text.trim(),
      targetValue: targetVal,
      startDate: _startDate,
      frequency: _selectedFrequency,
      colorHex: colorHex,
    );

    try {
      await ref.read(trendsProvider.notifier).updateTrend(updated);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trend updated successfully!')),
      );
      context.pop();
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

    if (trend == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Trend')),
        body: const AppErrorState(message: 'Trend not found.'),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.editTrend, style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Trend Name *',
                    controller: _nameController,
                    validator: (v) => AppValidators.requiredField(v, 'Trend name is required'),
                  ),
                  AppSpacing.vLg,
                  AppTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                  AppSpacing.vLg,
                  Text(
                    'Category *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.vSm,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryModel.defaultCategories.map((cat) {
                      final isSelected = _selectedCategory == cat.name;
                      return AppChip(
                        label: cat.name,
                        icon: cat.icon,
                        color: cat.color,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedCategory = cat.name),
                      );
                    }).toList(),
                  ),
                  AppSpacing.vLg,
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Unit *',
                          controller: _unitController,
                          validator: (v) => AppValidators.requiredField(v, 'Unit is required'),
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: AppTextField(
                          label: 'Target Value *',
                          controller: _targetValueController,
                          keyboardType: TextInputType.number,
                          validator: AppValidators.positiveNumber,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vLg,
                  Text(
                    'Tracking Frequency *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                        onTap: () => setState(() => _selectedFrequency = freq),
                      );
                    }).toList(),
                  ),
                  AppSpacing.vLg,
                  Text(
                    'Start Date *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.vSm,
                  InkWell(
                    onTap: _pickStartDate,
                    borderRadius: AppRadius.allMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
                        borderRadius: AppRadius.allMd,
                        border: Border.all(
                          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppDateFormatter.medium(_startDate),
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
                  Text(
                    'Accent Color',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.vSm,
                  Row(
                    children: _availableColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  AppSpacing.vGiant,
                  AppButton(
                    text: 'Save Changes',
                    height: 52,
                    isLoading: _isLoading,
                    icon: Icons.check_rounded,
                    onPressed: _handleUpdate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

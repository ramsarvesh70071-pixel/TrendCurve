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
import '../../data/models/trend_model.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/app_text_field.dart';

class CreateTrendScreen extends ConsumerStatefulWidget {
  const CreateTrendScreen({super.key});

  @override
  ConsumerState<CreateTrendScreen> createState() => _CreateTrendScreenState();
}

class _CreateTrendScreenState extends ConsumerState<CreateTrendScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController(text: '₹');
  final _initialValueController = TextEditingController(text: '0');
  final _targetValueController = TextEditingController();

  String _selectedCategory = 'Business';
  String _selectedFrequency = 'Monthly';
  DateTime _startDate = DateTime.now();
  Color _selectedColor = AppColors.primary;
  bool _isLoading = false;

  final List<Color> _availableColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Crimson
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF3B82F6), // Blue
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _initialValueController.dispose();
    _targetValueController.dispose();
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final initialVal = double.tryParse(_initialValueController.text.trim()) ?? 0.0;
    final targetVal = double.tryParse(_targetValueController.text.trim()) ?? 0.0;

    final colorHex = '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}';

    final trend = TrendModel(
      id: '', // Will be assigned by service
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      unit: _unitController.text.trim(),
      currentValue: initialVal,
      previousValue: initialVal,
      targetValue: targetVal,
      startDate: _startDate,
      frequency: _selectedFrequency,
      iconName: 'trending_up',
      colorHex: colorHex,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dataPoints: [],
    );

    try {
      final created = await ref.read(trendsProvider.notifier).createTrend(trend);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trend "${created.name}" created successfully!')),
      );
      // Navigate to Trend Details as required by prompt
      context.go('/trend-details/${created.id}');
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.createTrend, style: TextStyle(fontWeight: FontWeight.w800)),
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
                    hint: 'e.g. Monthly Revenue, Study Hours',
                    controller: _nameController,
                    validator: (v) => AppValidators.requiredField(v, 'Trend name is required'),
                  ),
                  AppSpacing.vLg,
                  AppTextField(
                    label: 'Description (Optional)',
                    hint: 'Brief details on what this metric represents',
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                  AppSpacing.vLg,

                  // Category Selection
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
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat.name;
                            _selectedColor = cat.color;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  AppSpacing.vLg,

                  // Unit & Values
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Unit / Symbol *',
                          hint: 'e.g. ₹, \$, kg, hrs',
                          controller: _unitController,
                          validator: (v) => AppValidators.requiredField(v, 'Unit is required'),
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: AppTextField(
                          label: 'Initial Value',
                          hint: '0',
                          controller: _initialValueController,
                          keyboardType: TextInputType.number,
                          validator: AppValidators.number,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vLg,
                  AppTextField(
                    label: 'Target Value (Goal) *',
                    hint: 'e.g. 100000',
                    controller: _targetValueController,
                    keyboardType: TextInputType.number,
                    validator: (v) => AppValidators.positiveNumber(v),
                  ),
                  AppSpacing.vLg,

                  // Frequency Selection
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

                  // Start Date Picker
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

                  // Color Picker
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      )
                                    ]
                                  : null,
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
                    text: 'Save & Track Curve',
                    height: 52,
                    isLoading: _isLoading,
                    icon: Icons.check_rounded,
                    onPressed: _handleSave,
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

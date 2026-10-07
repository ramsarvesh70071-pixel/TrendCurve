import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/number_formatter.dart';
import '../../shared/charts/comparison_chart.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/percentage_indicator.dart';
import '../../shared/widgets/section_header.dart';

class CompareTrendsScreen extends ConsumerStatefulWidget {
  const CompareTrendsScreen({super.key});

  @override
  ConsumerState<CompareTrendsScreen> createState() => _CompareTrendsScreenState();
}

class _CompareTrendsScreenState extends ConsumerState<CompareTrendsScreen> {
  final List<String> _selectedTrendIds = [];
  bool _isInitialized = false;

  final List<Color> _palette = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    AppColors.warning,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final trends = ref.read(filteredTrendsProvider);
      if (trends.length >= 2) {
        _selectedTrendIds.add(trends[0].id);
        _selectedTrendIds.add(trends[1].id);
      } else if (trends.isNotEmpty) {
        _selectedTrendIds.add(trends[0].id);
      }
      _isInitialized = true;
    }
  }

  void _toggleTrend(String id) {
    setState(() {
      if (_selectedTrendIds.contains(id)) {
        if (_selectedTrendIds.length > 1) {
          _selectedTrendIds.remove(id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('At least one trend must be selected.')),
          );
        }
      } else {
        if (_selectedTrendIds.length < 3) {
          _selectedTrendIds.add(id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can compare up to 3 trends simultaneously.')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTrends = ref.watch(filteredTrendsProvider);

    if (allTrends.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Trends')),
        body: const AppEmptyState(
          title: 'No Trends Available',
          subtitle: 'Create at least two trends to compare curves.',
        ),
      );
    }

    final selectedTrends =
        allTrends.where((t) => _selectedTrendIds.contains(t.id)).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Compare Trends', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SELECTION CHIPS ---
              Text(
                'Select Trends to Compare (Max 3)',
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
                children: allTrends.map((t) {
                  final isSelected = _selectedTrendIds.contains(t.id);
                  final idx = _selectedTrendIds.indexOf(t.id);
                  final color = idx != -1 ? _palette[idx % _palette.length] : AppColors.primary;

                  return AppChip(
                    label: t.name,
                    isSelected: isSelected,
                    color: color,
                    onTap: () => _toggleTrend(t.id),
                  );
                }).toList(),
              ),
              AppSpacing.vLg,

              // --- COMBINED MULTI-LINE CHART ---
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combined Performance Curve',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppSpacing.vSm,
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: List.generate(selectedTrends.length, (i) {
                        final t = selectedTrends[i];
                        final c = _palette[i % _palette.length];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                            AppSpacing.hXs,
                            Text(
                              t.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    AppSpacing.vLg,
                    ComparisonChart(trends: selectedTrends, height: 240),
                  ],
                ),
              ),
              AppSpacing.vLg,

              // --- INDIVIDUAL STATISTICS COMPARISON TABLE/CARDS ---
              SectionHeader(title: 'Direct Metrics Comparison'),
              ...List.generate(selectedTrends.length, (i) {
                final t = selectedTrends[i];
                final color = _palette[i % _palette.length];
                final stats = t.statistics;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                AppSpacing.hSm,
                                Text(
                                  t.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            PercentageIndicator(percentage: t.percentageGrowth),
                          ],
                        ),
                        AppSpacing.vMd,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniMetric('Current', AppNumberFormatter.formatValue(t.currentValue, t.unit), isDark),
                            _buildMiniMetric('Average', AppNumberFormatter.formatValue(stats.averageValue, t.unit), isDark),
                            _buildMiniMetric('Highest', AppNumberFormatter.formatValue(stats.highestValue, t.unit), isDark),
                            _buildMiniMetric('Goal', AppNumberFormatter.formatValue(t.targetValue, t.unit), isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // --- PERCENTAGE DIFFERENCE SUMMARY ---
              if (selectedTrends.length >= 2) ...[
                AppSpacing.vMd,
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  color: isDark
                      ? AppColors.primaryContainerDark.withValues(alpha: 0.3)
                      : AppColors.primaryContainerLight.withValues(alpha: 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.insights_rounded, size: 20, color: AppColors.primary),
                          AppSpacing.hSm,
                          Text(
                            'Comparative Growth Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Builder(builder: (_) {
                        final t1 = selectedTrends[0];
                        final t2 = selectedTrends[1];
                        final diff = (t1.percentageGrowth - t2.percentageGrowth).abs();
                        final leader = t1.percentageGrowth >= t2.percentageGrowth ? t1.name : t2.name;

                        return Text(
                          '$leader leads with a ${diff.toStringAsFixed(1)}% higher growth momentum between the two series.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              AppSpacing.vGiant,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        AppSpacing.vXxs,
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

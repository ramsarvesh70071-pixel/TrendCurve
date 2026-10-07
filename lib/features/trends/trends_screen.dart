import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/filter_criteria.dart';
import '../../data/models/sort_option.dart';
import '../../shared/widgets/app_bottom_sheet.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/trend_card.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  final _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    final currentSort = ref.read(trendSortOptionProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Sort Trends By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                AppSpacing.vMd,
                ...TrendSortOption.values.map((option) {
                  final isSelected = currentSort == option;
                  return ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref.read(trendSortOptionProvider.notifier).setSort(option);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    final currentFilter = ref.read(trendFilterCriteriaProvider);
    AppBottomSheet.show(
      context: context,
      title: 'Filter Trends',
      child: FilterBottomSheet(
        initialCriteria: currentFilter,
        onApply: (newCriteria) {
          ref.read(trendFilterCriteriaProvider.notifier).setFilter(newCriteria);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTrends = ref.watch(filteredTrendsProvider);
    final filter = ref.watch(trendFilterCriteriaProvider);
    final sort = ref.watch(trendSortOptionProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: _isSearchExpanded
            ? SearchField(
                controller: _searchController,
                autoFocus: true,
                onChanged: (q) => ref.read(trendSearchQueryProvider.notifier).setQuery(q),
                onClear: () => ref.read(trendSearchQueryProvider.notifier).setQuery(''),
              )
            : const Text(
                AppStrings.yourTrends,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
        actions: [
          AppIconButton(
            icon: _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
            tooltip: _isSearchExpanded ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  ref.read(trendSearchQueryProvider.notifier).setQuery('');
                }
              });
            },
          ),
          AppSpacing.hXs,
          Stack(
            children: [
              AppIconButton(
                icon: Icons.filter_list_rounded,
                tooltip: 'Filter',
                onPressed: _showFilterSheet,
              ),
              if (!filter.isEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.hXs,
          AppIconButton(
            icon: Icons.sort_rounded,
            tooltip: 'Sort: ${sort.label}',
            onPressed: _showSortDialog,
          ),
          AppSpacing.hMd,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Active filters horizontal strip if any filter is active
            if (!filter.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (filter.category != null) ...[
                        AppChip(
                          label: 'Category: ${filter.category}',
                          isSelected: true,
                          onTap: () {
                            ref.read(trendFilterCriteriaProvider.notifier).setFilter(
                                filter.copyWith(clearCategory: true));
                          },
                        ),
                        AppSpacing.hSm,
                      ],
                      if (filter.direction != null) ...[
                        AppChip(
                          label: 'Direction: ${filter.direction!.name}',
                          isSelected: true,
                          onTap: () {
                            ref.read(trendFilterCriteriaProvider.notifier).setFilter(
                                filter.copyWith(clearDirection: true));
                          },
                        ),
                        AppSpacing.hSm,
                      ],
                      if (filter.frequency != null) ...[
                        AppChip(
                          label: 'Freq: ${filter.frequency}',
                          isSelected: true,
                          onTap: () {
                            ref.read(trendFilterCriteriaProvider.notifier).setFilter(
                                filter.copyWith(clearFrequency: true));
                          },
                        ),
                        AppSpacing.hSm,
                      ],
                      TextButton(
                        onPressed: () {
                          ref.read(trendFilterCriteriaProvider.notifier).setFilter(
                              FilterCriteria.empty);
                        },
                        child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Expanded(
              child: filteredTrends.isEmpty
                  ? AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: AppStrings.noSearchResults,
                      subtitle: AppStrings.noSearchResultsSubtitle,
                      actionText: 'Reset Filters',
                      onAction: () {
                        _searchController.clear();
                        ref.read(trendSearchQueryProvider.notifier).setQuery('');
                        ref.read(trendFilterCriteriaProvider.notifier).setFilter(
                            FilterCriteria.empty);
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(trendsProvider.notifier).loadTrends();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: filteredTrends.length,
                        separatorBuilder: (_, __) => AppSpacing.vMd,
                        itemBuilder: (context, index) {
                          final trend = filteredTrends[index];
                          return TrendCard(
                            trend: trend,
                            onTap: () => context.push('/trend-details/${trend.id}'),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Trend', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => context.push('/create-trend'),
      ),
    );
  }
}

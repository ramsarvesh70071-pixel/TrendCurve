import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/trend_model.dart';
import '../../shared/widgets/activity_tile.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/trend_card.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTrends = ref.watch(trendsProvider).value ?? [];
    final allActivities = ref.watch(activityProvider);

    final cleanQuery = _query.trim().toLowerCase();

    final matchedTrends = cleanQuery.isEmpty
        ? <TrendModel>[]
        : allTrends.where((t) {
            return t.name.toLowerCase().contains(cleanQuery) ||
                t.category.toLowerCase().contains(cleanQuery) ||
                t.description.toLowerCase().contains(cleanQuery);
          }).toList();

    final matchedActivities = cleanQuery.isEmpty
        ? <ActivityModel>[]
        : allActivities.where((a) {
            return a.title.toLowerCase().contains(cleanQuery) ||
                a.description.toLowerCase().contains(cleanQuery);
          }).toList();

    // Data points matching query notes
    final matchedPoints = <Map<String, dynamic>>[];
    if (cleanQuery.isNotEmpty) {
      for (final t in allTrends) {
        for (final p in t.dataPoints) {
          if (p.note != null && p.note!.toLowerCase().contains(cleanQuery)) {
            matchedPoints.add({'trend': t, 'point': p});
          }
        }
      }
    }

    final hasMatches = matchedTrends.isNotEmpty ||
        matchedActivities.isNotEmpty ||
        matchedPoints.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: SearchField(
          controller: _searchController,
          autoFocus: true,
          hint: 'Search trends, logs, notes...',
          onChanged: (q) => setState(() => _query = q),
          onClear: () => setState(() => _query = ''),
        ),
      ),
      body: SafeArea(
        child: cleanQuery.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, size: 48, color: AppColors.primary),
                      AppSpacing.vLg,
                      Text(
                        'Type to search anything',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppSpacing.vSm,
                      Text(
                        'Search across your trends, category tags, activity timeline, and data point notes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : !hasMatches
                ? AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: AppStrings.noSearchResults,
                    subtitle: 'No trends, data points, or activities matched "$cleanQuery".',
                    actionText: 'Clear Query',
                    onAction: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (matchedTrends.isNotEmpty) ...[
                          SectionHeader(title: 'Matched Trends (${matchedTrends.length})'),
                          ...matchedTrends.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: TrendCard(
                                  trend: t,
                                  onTap: () => context.push('/trend-details/${t.id}'),
                                ),
                              )),
                          AppSpacing.vLg,
                        ],
                        if (matchedPoints.isNotEmpty) ...[
                          SectionHeader(title: 'Matched Data Point Notes (${matchedPoints.length})'),
                          ...matchedPoints.map((item) {
                            final t = item['trend'] as TrendModel;
                            final p = item['point'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: AppCard(
                                onTap: () => context.push('/trend-details/${t.id}'),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    const Icon(Icons.note_alt_outlined, size: 20, color: AppColors.primary),
                                    AppSpacing.hMd,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${t.name}: ${AppNumberFormatter.formatValue(p.value, t.unit)}',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                          ),
                                          AppSpacing.vXxs,
                                          Text(
                                            p.note ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          AppSpacing.vLg,
                        ],
                        if (matchedActivities.isNotEmpty) ...[
                          SectionHeader(title: 'Matched Activities (${matchedActivities.length})'),
                          ...matchedActivities.map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: ActivityTile(
                                  activity: a,
                                  onTap: a.trendId != null
                                      ? () => context.push('/trend-details/${a.trendId}')
                                      : null,
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}

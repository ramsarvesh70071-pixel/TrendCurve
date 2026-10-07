import '../models/filter_criteria.dart';
import '../models/sort_option.dart';
import '../models/trend_data_point_model.dart';
import '../models/trend_model.dart';
import '../services/trend_service.dart';

class TrendRepository {
  final TrendService _trendService;

  TrendRepository(this._trendService);

  Future<List<TrendModel>> getTrends({
    FilterCriteria? filter,
    TrendSortOption sort = TrendSortOption.recentlyUpdated,
    String? searchQuery,
    bool includeArchived = false,
  }) async {
    final all = await _trendService.getTrends();

    var list = all.where((t) {
      if (!includeArchived && t.isArchived) return false;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesName = t.name.toLowerCase().contains(query);
        final matchesCat = t.category.toLowerCase().contains(query);
        final matchesDesc = t.description.toLowerCase().contains(query);
        if (!matchesName && !matchesCat && !matchesDesc) return false;
      }
      if (filter != null) {
        if (filter.category != null && filter.category!.isNotEmpty) {
          if (t.category.toLowerCase() != filter.category!.toLowerCase()) return false;
        }
        if (filter.direction != null) {
          if (t.direction != filter.direction) return false;
        }
        if (filter.frequency != null && filter.frequency!.isNotEmpty) {
          if (t.frequency.toLowerCase() != filter.frequency!.toLowerCase()) return false;
        }
        if (filter.minValue != null) {
          if (t.currentValue < filter.minValue!) return false;
        }
        if (filter.maxValue != null) {
          if (t.currentValue > filter.maxValue!) return false;
        }
        if (filter.dateRange != null) {
          if (t.startDate.isBefore(filter.dateRange!.start) ||
              t.startDate.isAfter(filter.dateRange!.end)) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    // Apply sorting
    switch (sort) {
      case TrendSortOption.recentlyUpdated:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case TrendSortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case TrendSortOption.highestGrowth:
        list.sort((a, b) => b.percentageGrowth.compareTo(a.percentageGrowth));
        break;
      case TrendSortOption.lowestGrowth:
        list.sort((a, b) => a.percentageGrowth.compareTo(b.percentageGrowth));
        break;
      case TrendSortOption.highestValue:
        list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
        break;
      case TrendSortOption.lowestValue:
        list.sort((a, b) => a.currentValue.compareTo(b.currentValue));
        break;
    }

    return list;
  }

  Future<TrendModel> getTrendById(String id) => _trendService.getTrendById(id);

  Future<TrendModel> createTrend(TrendModel trend) =>
      _trendService.createTrend(trend);

  Future<TrendModel> updateTrend(TrendModel trend) =>
      _trendService.updateTrend(trend);

  Future<void> deleteTrend(String id) => _trendService.deleteTrend(id);

  Future<TrendModel> duplicateTrend(String id) =>
      _trendService.duplicateTrend(id);

  Future<TrendModel> toggleArchive(String id) =>
      _trendService.toggleArchive(id);

  Future<TrendModel> addDataPoint(
          String trendId, TrendDataPointModel dataPoint) =>
      _trendService.addDataPoint(trendId, dataPoint);

  Future<TrendModel> updateDataPoint(
          String trendId, TrendDataPointModel dataPoint) =>
      _trendService.updateDataPoint(trendId, dataPoint);

  Future<TrendModel> deleteDataPoint(String trendId, String pointId) =>
      _trendService.deleteDataPoint(trendId, pointId);
}

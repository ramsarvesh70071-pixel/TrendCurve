import 'package:uuid/uuid.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../local/local_storage_service.dart';
import '../models/trend_model.dart';
import '../models/trend_data_point_model.dart';

abstract class TrendService {
  Future<List<TrendModel>> getTrends();
  Future<TrendModel> getTrendById(String id);
  Future<TrendModel> createTrend(TrendModel trend);
  Future<TrendModel> updateTrend(TrendModel trend);
  Future<void> deleteTrend(String id);
  Future<TrendModel> duplicateTrend(String id);
  Future<TrendModel> toggleArchive(String id);
  Future<TrendModel> addDataPoint(String trendId, TrendDataPointModel dataPoint);
  Future<TrendModel> updateDataPoint(String trendId, TrendDataPointModel dataPoint);
  Future<TrendModel> deleteDataPoint(String trendId, String pointId);
}

class LocalTrendService implements TrendService {
  final LocalStorageService storage;
  final ApiClient? apiClient;
  final _uuid = const Uuid();

  LocalTrendService({
    required this.storage,
    this.apiClient,
  });

  @override
  Future<List<TrendModel>> getTrends() async {
    return storage.getTrends();
  }

  @override
  Future<TrendModel> getTrendById(String id) async {
    final list = storage.getTrends();
    final item = list.where((t) => t.id == id).firstOrNull;
    if (item == null) {
      throw const NotFoundException('Trend not found');
    }
    return item;
  }

  @override
  Future<TrendModel> createTrend(TrendModel trend) async {
    final list = storage.getTrends();
    final newId = trend.id.isEmpty ? _uuid.v4() : trend.id;

    // If initial value > 0 and no data points exist, add initial point
    List<TrendDataPointModel> points = List.from(trend.dataPoints);
    if (points.isEmpty && trend.currentValue > 0) {
      points.add(
        TrendDataPointModel(
          id: _uuid.v4(),
          trendId: newId,
          date: trend.startDate,
          value: trend.currentValue,
          note: 'Initial starting value',
          createdAt: DateTime.now(),
        ),
      );
    }

    final newTrend = trend.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dataPoints: points,
    );

    list.insert(0, newTrend);
    await storage.saveTrends(list);
    return newTrend;
  }

  @override
  Future<TrendModel> updateTrend(TrendModel trend) async {
    final list = storage.getTrends();
    final index = list.indexWhere((t) => t.id == trend.id);
    if (index == -1) {
      throw const NotFoundException('Trend not found to update');
    }

    final updated = trend.copyWith(updatedAt: DateTime.now());
    list[index] = updated;
    await storage.saveTrends(list);
    return updated;
  }

  @override
  Future<void> deleteTrend(String id) async {
    final list = storage.getTrends();
    list.removeWhere((t) => t.id == id);
    await storage.saveTrends(list);
  }

  @override
  Future<TrendModel> duplicateTrend(String id) async {
    final existing = await getTrendById(id);
    final duplicatedId = _uuid.v4();

    final duplicatedPoints = existing.dataPoints.map((p) {
      return p.copyWith(
        id: _uuid.v4(),
        trendId: duplicatedId,
      );
    }).toList();

    final duplicated = existing.copyWith(
      id: duplicatedId,
      name: '${existing.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dataPoints: duplicatedPoints,
    );

    return createTrend(duplicated);
  }

  @override
  Future<TrendModel> toggleArchive(String id) async {
    final existing = await getTrendById(id);
    final updated = existing.copyWith(
      isArchived: !existing.isArchived,
      updatedAt: DateTime.now(),
    );
    return updateTrend(updated);
  }

  @override
  Future<TrendModel> addDataPoint(
      String trendId, TrendDataPointModel dataPoint) async {
    final trend = await getTrendById(trendId);
    final newPoint = dataPoint.copyWith(
      id: dataPoint.id.isEmpty ? _uuid.v4() : dataPoint.id,
      trendId: trendId,
      createdAt: DateTime.now(),
    );

    final points = List<TrendDataPointModel>.from(trend.dataPoints)..add(newPoint);
    // Sort to obtain previous and latest values
    points.sort((a, b) => a.date.compareTo(b.date));

    final latestValue = points.last.value;
    final previousValue = points.length > 1
        ? points[points.length - 2].value
        : trend.currentValue;

    final updated = trend.copyWith(
      currentValue: latestValue,
      previousValue: previousValue,
      updatedAt: DateTime.now(),
      dataPoints: points,
    );

    await updateTrend(updated);
    return updated;
  }

  @override
  Future<TrendModel> updateDataPoint(
      String trendId, TrendDataPointModel dataPoint) async {
    final trend = await getTrendById(trendId);
    final points = List<TrendDataPointModel>.from(trend.dataPoints);
    final pIndex = points.indexWhere((p) => p.id == dataPoint.id);
    if (pIndex == -1) {
      throw const NotFoundException('Data point not found');
    }

    points[pIndex] = dataPoint;
    points.sort((a, b) => a.date.compareTo(b.date));

    final latestValue = points.last.value;
    final previousValue = points.length > 1
        ? points[points.length - 2].value
        : trend.currentValue;

    final updated = trend.copyWith(
      currentValue: latestValue,
      previousValue: previousValue,
      updatedAt: DateTime.now(),
      dataPoints: points,
    );

    await updateTrend(updated);
    return updated;
  }

  @override
  Future<TrendModel> deleteDataPoint(String trendId, String pointId) async {
    final trend = await getTrendById(trendId);
    final points = List<TrendDataPointModel>.from(trend.dataPoints)
      ..removeWhere((p) => p.id == pointId);

    points.sort((a, b) => a.date.compareTo(b.date));

    final latestValue = points.isNotEmpty ? points.last.value : 0.0;
    final previousValue = points.length > 1 ? points[points.length - 2].value : 0.0;

    final updated = trend.copyWith(
      currentValue: latestValue,
      previousValue: previousValue,
      updatedAt: DateTime.now(),
      dataPoints: points,
    );

    await updateTrend(updated);
    return updated;
  }
}

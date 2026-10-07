import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trend_curve/core/utils/growth_calculator.dart';
import 'package:trend_curve/data/local/local_storage_service.dart';
import 'package:trend_curve/data/models/filter_criteria.dart';
import 'package:trend_curve/data/models/sort_option.dart';
import 'package:trend_curve/data/models/trend_data_point_model.dart';
import 'package:trend_curve/data/models/trend_model.dart';
import 'package:trend_curve/data/repositories/trend_repository.dart';
import 'package:trend_curve/data/services/trend_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late TrendService service;
  late TrendRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    service = LocalTrendService(storage: storage);
    repository = TrendRepository(service);
  });

  group('TrendRepository CRUD and Operations', () {
    test('getTrends returns seeded trends initially', () async {
      final trends = await repository.getTrends();
      expect(trends.isNotEmpty, isTrue);
    });

    test('createTrend adds a new trend and initializes data point', () async {
      final initialCount = (await repository.getTrends()).length;
      final newTrend = TrendModel(
        id: 'test_123',
        name: 'Gym Attendance',
        description: 'Tracking workouts',
        category: 'Health',
        unit: 'days',
        currentValue: 12,
        targetValue: 20,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await repository.createTrend(newTrend);
      expect(created.name, equals('Gym Attendance'));

      final all = await repository.getTrends();
      expect(all.length, equals(initialCount + 1));
      expect(all.any((t) => t.id == 'test_123'), isTrue);
    });

    test('addDataPoint recalculates trend currentValue and updates list', () async {
      final trend = (await repository.getTrends()).first;
      final newPoint = TrendDataPointModel(
        id: 'dp_new_1',
        trendId: trend.id,
        date: DateTime.now(),
        value: 99999.0,
        note: 'Record peak',
        createdAt: DateTime.now(),
      );

      final updated = await repository.addDataPoint(trend.id, newPoint);
      expect(updated.currentValue, equals(99999.0));
      expect(updated.dataPoints.any((p) => p.id == 'dp_new_1'), isTrue);
    });

    test('deleteDataPoint removes point and updates latest value', () async {
      final trend = (await repository.getTrends()).first;
      final originalCount = trend.dataPoints.length;
      final firstPointId = trend.dataPoints.first.id;

      final updated = await repository.deleteDataPoint(trend.id, firstPointId);
      expect(updated.dataPoints.length, equals(originalCount - 1));
      expect(updated.dataPoints.any((p) => p.id == firstPointId), isFalse);
    });

    test('FilterCriteria correctly filters by category and direction', () async {
      final businessTrends = await repository.getTrends(
        filter: const FilterCriteria(category: 'Business'),
      );
      for (final t in businessTrends) {
        expect(t.category, equals('Business'));
      }

      final positiveTrends = await repository.getTrends(
        filter: const FilterCriteria(direction: TrendDirection.positive),
      );
      for (final t in positiveTrends) {
        expect(t.direction, equals(TrendDirection.positive));
      }
    });

    test('TrendSortOption orders list correctly', () async {
      final sortedByName = await repository.getTrends(sort: TrendSortOption.nameAsc);
      for (int i = 0; i < sortedByName.length - 1; i++) {
        expect(
          sortedByName[i].name.toLowerCase().compareTo(sortedByName[i + 1].name.toLowerCase()) <= 0,
          isTrue,
        );
      }
    });

    test('duplicateTrend clones trend with unique id and suffix', () async {
      final trend = (await repository.getTrends()).first;
      final dup = await repository.duplicateTrend(trend.id);

      expect(dup.id, isNot(equals(trend.id)));
      expect(dup.name, contains('(Copy)'));
      expect(dup.dataPoints.length, equals(trend.dataPoints.length));
    });

    test('toggleArchive toggles trend archive state', () async {
      final trend = (await repository.getTrends()).first;
      final archived = await repository.toggleArchive(trend.id);
      expect(archived.isArchived, isTrue);

      final activeTrends = await repository.getTrends(includeArchived: false);
      expect(activeTrends.any((t) => t.id == trend.id), isFalse);
    });
  });
}

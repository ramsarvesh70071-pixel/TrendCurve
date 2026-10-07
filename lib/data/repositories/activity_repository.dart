import 'package:uuid/uuid.dart';
import '../local/local_storage_service.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  final LocalStorageService _storage;
  final _uuid = const Uuid();

  ActivityRepository(this._storage);

  Future<List<ActivityModel>> getActivities({String? searchQuery}) async {
    final list = _storage.getActivities();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      return list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> logActivity({
    required String title,
    required String description,
    String iconName = 'timeline',
    String? trendId,
  }) async {
    final list = _storage.getActivities();
    final newActivity = ActivityModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      timestamp: DateTime.now(),
      iconName: iconName,
      trendId: trendId,
    );
    list.insert(0, newActivity);
    await _storage.saveActivities(list);
  }

  Future<void> clearAll() async {
    await _storage.saveActivities([]);
  }
}

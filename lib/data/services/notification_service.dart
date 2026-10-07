import '../local/local_storage_service.dart';
import '../models/notification_model.dart';

abstract class NotificationService {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> addNotification(NotificationModel notification);
}

class LocalNotificationService implements NotificationService {
  final LocalStorageService storage;

  LocalNotificationService({required this.storage});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return storage.getNotifications();
  }

  @override
  Future<void> markAsRead(String id) async {
    final list = storage.getNotifications();
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(isRead: true);
      await storage.saveNotifications(list);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final list = storage.getNotifications();
    final updated = list.map((n) => n.copyWith(isRead: true)).toList();
    await storage.saveNotifications(updated);
  }

  @override
  Future<void> deleteNotification(String id) async {
    final list = storage.getNotifications();
    list.removeWhere((n) => n.id == id);
    await storage.saveNotifications(list);
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    final list = storage.getNotifications();
    list.insert(0, notification);
    await storage.saveNotifications(list);
  }
}

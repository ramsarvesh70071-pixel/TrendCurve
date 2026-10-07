import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository(this._service);

  Future<List<NotificationModel>> getNotifications() =>
      _service.getNotifications();

  Future<void> markAsRead(String id) => _service.markAsRead(id);

  Future<void> markAllAsRead() => _service.markAllAsRead();

  Future<void> deleteNotification(String id) =>
      _service.deleteNotification(id);

  Future<void> addNotification(NotificationModel notification) =>
      _service.addNotification(notification);
}

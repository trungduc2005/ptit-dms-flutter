import 'package:ptit_dms_flutter/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<NotificationPage> getNotifications({
    int limit = 20,
    DateTime? cursor,
    bool unreadOnly = false,
  });

  Future<void> markAsRead(String notificationId);

  Future<int> markAllAsRead();
}

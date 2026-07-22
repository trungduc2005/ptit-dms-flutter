import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NotificationPage> getNotifications({
    int limit = 20,
    DateTime? cursor,
    bool unreadOnly = false,
  }) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor.toUtc().toIso8601String(),
        if (unreadOnly) 'unread': true,
      },
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final json = asJsonMap(response.data);
    final notifications = asJsonList(
      json['data'],
    ).map(Notification.fromJson).toList(growable: false);

    return NotificationPage(
      notifications: notifications,
      hasMore: asBool(json['hasMore']) ?? false,
      nextCursor: asDateTime(json['nextCursor']),
      totalUnread: asInt(json['totalUnread']),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.post(
      '/notifications/$notificationId/read',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
  }

  Future<int> markAllAsRead() async {
    final response = await _dio.post(
      '/notifications/read-all',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final json = asJsonMap(response.data);
    final inserted = asInt(json['inserted']);
    if (inserted == null) {
      throw const FormatException('Notification mark-all response is invalid.');
    }

    return inserted;
  }
}

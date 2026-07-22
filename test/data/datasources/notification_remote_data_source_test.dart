import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/notification_remote_data_source.dart';

void main() {
  Dio createStubDio(
    Object? Function(RequestOptions options) responseData, {
    void Function(RequestOptions options)? capture,
  }) {
    return Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capture?.call(options);
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: responseData(options),
              ),
            );
          },
        ),
      );
  }

  group('NotificationRemoteDataSource', () {
    test('gets and parses a notification page with filters', () async {
      RequestOptions? captured;
      final cursor = DateTime.parse('2026-07-22T06:00:00.000Z');
      final dataSource = NotificationRemoteDataSource(
        createStubDio(
          (_) => {
            'data': [
              {
                '_id': 'notification-01',
                'recipient': 'student-01',
                'title': 'Thông báo mới',
                'shortContent': 'Nội dung ngắn',
                'details': 'Nội dung chi tiết',
                'sender': 'Phòng đào tạo',
                'sentAt': '2026-07-22T05:30:00.000Z',
                'isRead': false,
              },
            ],
            'hasMore': true,
            'nextCursor': '2026-07-22T05:30:00.000Z',
            'totalUnread': 3,
          },
          capture: (options) => captured = options,
        ),
      );

      final page = await dataSource.getNotifications(
        limit: 10,
        cursor: cursor,
        unreadOnly: true,
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, '/notifications');
      expect(captured!.queryParameters, {
        'limit': 10,
        'cursor': '2026-07-22T06:00:00.000Z',
        'unread': true,
      });
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(page.notifications, hasLength(1));
      expect(page.notifications.single.id, 'notification-01');
      expect(page.notifications.single.title, 'Thông báo mới');
      expect(page.notifications.single.isRead, isFalse);
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, DateTime.parse('2026-07-22T05:30:00.000Z'));
      expect(page.totalUnread, 3);
    });

    test('omits optional query parameters when filters are not set', () async {
      RequestOptions? captured;
      final dataSource = NotificationRemoteDataSource(
        createStubDio(
          (_) => {
            'data': <Object?>[],
            'hasMore': false,
            'nextCursor': null,
            'totalUnread': 0,
          },
          capture: (options) => captured = options,
        ),
      );

      final page = await dataSource.getNotifications();

      expect(captured!.queryParameters, {'limit': 20});
      expect(page.notifications, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
      expect(page.totalUnread, 0);
    });

    test('marks one notification as read', () async {
      RequestOptions? captured;
      final dataSource = NotificationRemoteDataSource(
        createStubDio((_) => null, capture: (options) => captured = options),
      );

      await dataSource.markAsRead('notification-01');

      expect(captured!.method, 'POST');
      expect(captured!.path, '/notifications/notification-01/read');
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
    });

    test(
      'marks all notifications as read and returns inserted count',
      () async {
        RequestOptions? captured;
        final dataSource = NotificationRemoteDataSource(
          createStubDio(
            (_) => {'inserted': 4},
            capture: (options) => captured = options,
          ),
        );

        final inserted = await dataSource.markAllAsRead();

        expect(captured!.method, 'POST');
        expect(captured!.path, '/notifications/read-all');
        expect(captured!.extra[requiresBearerAuthKey], isTrue);
        expect(inserted, 4);
      },
    );

    test(
      'throws FormatException when notification data is malformed',
      () async {
        final dataSource = NotificationRemoteDataSource(
          createStubDio(
            (_) => {
              'data': [
                {'title': 'Thiếu mã và thời gian gửi'},
              ],
              'hasMore': false,
            },
          ),
        );

        expect(
          () => dataSource.getNotifications(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'throws FormatException when mark-all response has no inserted count',
      () async {
        final dataSource = NotificationRemoteDataSource(
          createStubDio((_) => {'message': 'Thành công'}),
        );

        expect(
          () => dataSource.markAllAsRead(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

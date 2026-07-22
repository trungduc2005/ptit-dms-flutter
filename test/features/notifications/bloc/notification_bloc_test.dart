import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart';
import 'package:ptit_dms_flutter/domain/repositories/notification_repository.dart';
import 'package:ptit_dms_flutter/features/notifications/bloc/notification_bloc.dart';

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

final _sentAt = DateTime.utc(2026, 7, 22, 6);
final _nextCursor = DateTime.utc(2026, 7, 21, 6);

late Notification _unreadNotification;
late Notification _readNotification;

void main() {
  late _MockNotificationRepository repository;

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2000));
  });

  setUp(() {
    repository = _MockNotificationRepository();
    _unreadNotification = Notification(
      id: 'n1',
      recipient: 'student',
      title: 'Thông báo mới',
      shortContent: 'Nội dung ngắn',
      details: 'Nội dung chi tiết',
      sender: 'admin',
      sentAt: _sentAt,
      isRead: false,
    );
    _readNotification = Notification(
      id: 'n2',
      recipient: 'student',
      title: 'Thông báo cũ',
      shortContent: 'Nội dung ngắn',
      details: 'Nội dung chi tiết',
      sender: 'admin',
      sentAt: _sentAt.subtract(const Duration(days: 1)),
      isRead: true,
    );
  });

  NotificationBloc buildBloc() => NotificationBloc(repository);

  void stubFirstPage({
    required NotificationPage page,
    bool unreadOnly = false,
  }) {
    when(
      () => repository.getNotifications(
        limit: 20,
        cursor: null,
        unreadOnly: unreadOnly,
      ),
    ).thenAnswer((_) async => page);
  }

  group('NotificationBloc', () {
    test('initial state is NotificationState()', () {
      expect(buildBloc().state, const NotificationState());
    });

    blocTest<NotificationBloc, NotificationState>(
      'loads the first page when started',
      setUp: () {
        stubFirstPage(
          page: NotificationPage(
            notifications: [_unreadNotification],
            hasMore: true,
            nextCursor: _nextCursor,
            totalUnread: 3,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const NotificationStarted()),
      expect: () => [
        const NotificationState(status: NotificationStatus.loading),
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification],
          hasMore: true,
          nextCursor: _nextCursor,
          totalUnread: 3,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getNotifications(
            limit: 20,
            cursor: null,
            unreadOnly: false,
          ),
        ).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'keeps current notifications and exposes failure when refresh fails',
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_readNotification],
      ),
      setUp: () {
        when(
          () => repository.getNotifications(
            limit: 20,
            cursor: null,
            unreadOnly: false,
          ),
        ).thenThrow(NetworkException('Không có kết nối mạng'));
      },
      act: (bloc) => bloc.add(const NotificationRefreshed()),
      expect: () => [
        NotificationState(
          status: NotificationStatus.loading,
          notifications: [_readNotification],
        ),
        NotificationState(
          status: NotificationStatus.failure,
          notifications: [_readNotification],
          errorMessage: 'Không có kết nối mạng',
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'changes unread filter and reloads the first page',
      setUp: () {
        stubFirstPage(
          unreadOnly: true,
          page: NotificationPage(
            notifications: [_unreadNotification],
            hasMore: false,
            nextCursor: null,
            totalUnread: 1,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const NotificationFilterChanged(unreadOnly: true)),
      expect: () => [
        const NotificationState(unreadOnly: true),
        const NotificationState(
          status: NotificationStatus.loading,
          unreadOnly: true,
        ),
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification],
          totalUnread: 1,
          unreadOnly: true,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'restores a previously loaded filter from cache without another request',
      setUp: () {
        stubFirstPage(
          page: NotificationPage(
            notifications: [_unreadNotification, _readNotification],
            hasMore: true,
            nextCursor: _nextCursor,
            totalUnread: 1,
          ),
        );
        stubFirstPage(
          unreadOnly: true,
          page: NotificationPage(
            notifications: [_unreadNotification],
            hasMore: false,
            nextCursor: null,
            totalUnread: 1,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const NotificationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const NotificationFilterChanged(unreadOnly: true));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const NotificationFilterChanged(unreadOnly: false));
      },
      skip: 5,
      expect: () => [
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification, _readNotification],
          hasMore: true,
          nextCursor: _nextCursor,
          totalUnread: 1,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getNotifications(
            limit: 20,
            cursor: null,
            unreadOnly: false,
          ),
        ).called(1);
        verify(
          () => repository.getNotifications(
            limit: 20,
            cursor: null,
            unreadOnly: true,
          ),
        ).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'loads more with cursor and removes duplicate notifications',
      setUp: () {
        when(
          () => repository.getNotifications(
            limit: 20,
            cursor: _nextCursor,
            unreadOnly: false,
          ),
        ).thenAnswer(
          (_) async => NotificationPage(
            notifications: [_unreadNotification, _readNotification],
            hasMore: false,
            nextCursor: null,
            totalUnread: 1,
          ),
        );
      },
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_unreadNotification],
        hasMore: true,
        nextCursor: _nextCursor,
        totalUnread: 1,
      ),
      act: (bloc) => bloc.add(const NotificationLoadMore()),
      expect: () => [
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification],
          hasMore: true,
          nextCursor: _nextCursor,
          totalUnread: 1,
          loadMoreStatus: NotificationLoadMoreStatus.loading,
        ),
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification, _readNotification],
          totalUnread: 1,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'does not request more when there is no next page',
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_unreadNotification],
      ),
      act: (bloc) => bloc.add(const NotificationLoadMore()),
      expect: () => <NotificationState>[],
      verify: (_) => verifyNever(
        () => repository.getNotifications(
          limit: any(named: 'limit'),
          cursor: any(named: 'cursor'),
          unreadOnly: any(named: 'unreadOnly'),
        ),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'marks one notification as read and decrements unread count',
      setUp: () {
        when(
          () => repository.markAsRead(_unreadNotification.id),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_unreadNotification, _readNotification],
        totalUnread: 2,
      ),
      act: (bloc) => bloc.add(NotificationMarkedAsRead(_unreadNotification.id)),
      expect: () => [
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification, _readNotification],
          totalUnread: 2,
          mutationStatus: NotificationMutationStatus.loading,
        ),
        NotificationState(
          status: NotificationStatus.success,
          notifications: [
            _unreadNotification.copyWith(isRead: true),
            _readNotification,
          ],
          totalUnread: 1,
          mutationStatus: NotificationMutationStatus.success,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'removes a read notification from the unread-only list',
      setUp: () {
        when(
          () => repository.markAsRead(_unreadNotification.id),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_unreadNotification],
        totalUnread: 1,
        unreadOnly: true,
      ),
      act: (bloc) => bloc.add(NotificationMarkedAsRead(_unreadNotification.id)),
      expect: () => [
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification],
          totalUnread: 1,
          unreadOnly: true,
          mutationStatus: NotificationMutationStatus.loading,
        ),
        const NotificationState(
          status: NotificationStatus.success,
          totalUnread: 0,
          unreadOnly: true,
          mutationStatus: NotificationMutationStatus.success,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'keeps data and exposes mutation error when mark as read fails',
      setUp: () {
        when(
          () => repository.markAsRead(_unreadNotification.id),
        ).thenThrow(ServerException('Không thể cập nhật'));
      },
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_unreadNotification],
        totalUnread: 1,
      ),
      act: (bloc) => bloc.add(NotificationMarkedAsRead(_unreadNotification.id)),
      expect: () => [
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification],
          totalUnread: 1,
          mutationStatus: NotificationMutationStatus.loading,
        ),
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification],
          totalUnread: 1,
          mutationStatus: NotificationMutationStatus.failure,
          mutationErrorMessage: 'Không thể cập nhật',
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'marks all notifications as read',
      setUp: () {
        when(() => repository.markAllAsRead()).thenAnswer((_) async => 2);
      },
      build: buildBloc,
      seed: () => NotificationState(
        status: NotificationStatus.success,
        notifications: [_unreadNotification, _readNotification],
        totalUnread: 2,
      ),
      act: (bloc) => bloc.add(const NotificationAllMarkedAsRead()),
      expect: () => [
        NotificationState(
          status: NotificationStatus.success,
          notifications: [_unreadNotification, _readNotification],
          totalUnread: 2,
          mutationStatus: NotificationMutationStatus.loading,
        ),
        NotificationState(
          status: NotificationStatus.success,
          notifications: [
            _unreadNotification.copyWith(isRead: true),
            _readNotification,
          ],
          mutationStatus: NotificationMutationStatus.success,
        ),
      ],
    );
  });

  group('NotificationState', () {
    test('copyWith can explicitly clear nullable values', () {
      final state = NotificationState(
        nextCursor: _nextCursor,
        errorMessage: 'error',
        mutationErrorMessage: 'mutation error',
      );

      final updated = state.copyWith(
        nextCursor: null,
        errorMessage: null,
        mutationErrorMessage: null,
      );

      expect(updated.nextCursor, isNull);
      expect(updated.errorMessage, isNull);
      expect(updated.mutationErrorMessage, isNull);
    });
  });
}

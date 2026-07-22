import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart';
import 'package:ptit_dms_flutter/domain/repositories/notification_repository.dart';

import 'notification_event.dart';
import 'notification_state.dart';

export 'notification_event.dart';
export 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._notificationRepository)
    : super(const NotificationState()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationRefreshed>(_onRefreshed);
    on<NotificationFilterChanged>(_onFilterChanged);
    on<NotificationLoadMore>(_onLoadMore);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<NotificationAllMarkedAsRead>(_onAllMarkedAsRead);
  }

  static const int _pageSize = 20;

  final NotificationRepository _notificationRepository;
  final Map<bool, _NotificationCache> _filterCache = {};

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    NotificationRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterChanged(
    NotificationFilterChanged event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.unreadOnly == state.unreadOnly &&
        state.status != NotificationStatus.initial) {
      return;
    }

    _cacheCurrentFilter();

    final cached = _filterCache[event.unreadOnly];
    if (cached != null) {
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: cached.notifications,
          hasMore: cached.hasMore,
          nextCursor: cached.nextCursor,
          totalUnread: cached.totalUnread,
          unreadOnly: event.unreadOnly,
          loadMoreStatus: NotificationLoadMoreStatus.idle,
          mutationStatus: NotificationMutationStatus.idle,
          errorMessage: null,
          mutationErrorMessage: null,
        ),
      );
      return;
    }

    emit(state.copyWith(unreadOnly: event.unreadOnly));
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<NotificationState> emit) async {
    emit(
      state.copyWith(
        status: NotificationStatus.loading,
        loadMoreStatus: NotificationLoadMoreStatus.idle,
        mutationStatus: NotificationMutationStatus.idle,
        errorMessage: null,
        mutationErrorMessage: null,
      ),
    );

    try {
      final page = await _notificationRepository.getNotifications(
        limit: _pageSize,
        unreadOnly: state.unreadOnly,
      );

      if (emit.isDone || isClosed) return;

      final nextState = state.copyWith(
        status: NotificationStatus.success,
        notifications: page.notifications,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        totalUnread: page.totalUnread ?? state.totalUnread,
        errorMessage: null,
      );
      _cacheState(nextState);
      emit(nextState);
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    NotificationLoadMore event,
    Emitter<NotificationState> emit,
  ) async {
    if (!state.canLoadMore) return;

    final cursor = state.nextCursor;
    if (cursor == null) return;

    emit(
      state.copyWith(
        loadMoreStatus: NotificationLoadMoreStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final page = await _notificationRepository.getNotifications(
        limit: _pageSize,
        cursor: cursor,
        unreadOnly: state.unreadOnly,
      );

      if (emit.isDone || isClosed) return;

      final nextState = state.copyWith(
        notifications: _mergeNotifications(
          state.notifications,
          page.notifications,
        ),
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        totalUnread: page.totalUnread ?? state.totalUnread,
        loadMoreStatus: NotificationLoadMoreStatus.idle,
        errorMessage: null,
      );
      _cacheState(nextState);
      emit(nextState);
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadMoreStatus: NotificationLoadMoreStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final index = state.notifications.indexWhere(
      (notification) => notification.id == event.notificationId,
    );
    if (index == -1 || state.notifications[index].isRead) return;

    emit(
      state.copyWith(
        mutationStatus: NotificationMutationStatus.loading,
        mutationErrorMessage: null,
      ),
    );

    try {
      await _notificationRepository.markAsRead(event.notificationId);

      if (emit.isDone || isClosed) return;

      final notifications = state.unreadOnly
          ? state.notifications
                .where(
                  (notification) => notification.id != event.notificationId,
                )
                .toList(growable: false)
          : state.notifications
                .map(
                  (notification) => notification.id == event.notificationId
                      ? notification.copyWith(isRead: true)
                      : notification,
                )
                .toList(growable: false);

      final totalUnread = state.totalUnread > 0 ? state.totalUnread - 1 : 0;
      _markAsReadInCache(event.notificationId, totalUnread);

      final nextState = state.copyWith(
        notifications: notifications,
        totalUnread: totalUnread,
        mutationStatus: NotificationMutationStatus.success,
        mutationErrorMessage: null,
      );
      _cacheState(nextState);
      emit(nextState);
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          mutationStatus: NotificationMutationStatus.failure,
          mutationErrorMessage: error.message,
        ),
      );
    }
  }

  Future<void> _onAllMarkedAsRead(
    NotificationAllMarkedAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.totalUnread == 0 &&
        state.notifications.every((notification) => notification.isRead)) {
      return;
    }

    emit(
      state.copyWith(
        mutationStatus: NotificationMutationStatus.loading,
        mutationErrorMessage: null,
      ),
    );

    try {
      await _notificationRepository.markAllAsRead();

      if (emit.isDone || isClosed) return;

      final notifications = state.unreadOnly
          ? const <Notification>[]
          : state.notifications
                .map((notification) => notification.copyWith(isRead: true))
                .toList(growable: false);

      _markAllAsReadInCache();

      final nextState = state.copyWith(
        notifications: notifications,
        totalUnread: 0,
        hasMore: state.unreadOnly ? false : state.hasMore,
        nextCursor: state.unreadOnly ? null : state.nextCursor,
        mutationStatus: NotificationMutationStatus.success,
        mutationErrorMessage: null,
      );
      _cacheState(nextState);
      emit(nextState);
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          mutationStatus: NotificationMutationStatus.failure,
          mutationErrorMessage: error.message,
        ),
      );
    }
  }

  void _cacheCurrentFilter() {
    if (state.status == NotificationStatus.success) {
      _cacheState(state);
    }
  }

  void _cacheState(NotificationState source) {
    _filterCache[source.unreadOnly] = _NotificationCache(
      notifications: source.notifications,
      hasMore: source.hasMore,
      nextCursor: source.nextCursor,
      totalUnread: source.totalUnread,
    );
  }

  void _markAsReadInCache(String notificationId, int totalUnread) {
    final allCache = _filterCache[false];
    if (allCache != null) {
      _filterCache[false] = allCache.copyWith(
        notifications: allCache.notifications
            .map(
              (notification) => notification.id == notificationId
                  ? notification.copyWith(isRead: true)
                  : notification,
            )
            .toList(growable: false),
        totalUnread: totalUnread,
      );
    }

    final unreadCache = _filterCache[true];
    if (unreadCache != null) {
      _filterCache[true] = unreadCache.copyWith(
        notifications: unreadCache.notifications
            .where((notification) => notification.id != notificationId)
            .toList(growable: false),
        totalUnread: totalUnread,
      );
    }
  }

  void _markAllAsReadInCache() {
    final allCache = _filterCache[false];
    if (allCache != null) {
      _filterCache[false] = allCache.copyWith(
        notifications: allCache.notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList(growable: false),
        totalUnread: 0,
      );
    }

    if (_filterCache.containsKey(true)) {
      _filterCache[true] = const _NotificationCache(
        notifications: [],
        hasMore: false,
        nextCursor: null,
        totalUnread: 0,
      );
    }
  }

  List<Notification> _mergeNotifications(
    List<Notification> current,
    List<Notification> incoming,
  ) {
    final ids = current.map((notification) => notification.id).toSet();

    return [
      ...current,
      ...incoming.where((notification) => ids.add(notification.id)),
    ];
  }
}

final class _NotificationCache {
  const _NotificationCache({
    required this.notifications,
    required this.hasMore,
    required this.nextCursor,
    required this.totalUnread,
  });

  final List<Notification> notifications;
  final bool hasMore;
  final DateTime? nextCursor;
  final int totalUnread;

  _NotificationCache copyWith({
    List<Notification>? notifications,
    bool? hasMore,
    DateTime? nextCursor,
    int? totalUnread,
  }) {
    return _NotificationCache(
      notifications: notifications ?? this.notifications,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      totalUnread: totalUnread ?? this.totalUnread,
    );
  }
}

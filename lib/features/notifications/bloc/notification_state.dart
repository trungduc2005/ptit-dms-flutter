import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart';

enum NotificationStatus { initial, loading, success, failure }

enum NotificationLoadMoreStatus { idle, loading, failure }

enum NotificationMutationStatus { idle, loading, success, failure }

const _unset = Object();

final class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.hasMore = false,
    this.nextCursor,
    this.totalUnread = 0,
    this.unreadOnly = false,
    this.loadMoreStatus = NotificationLoadMoreStatus.idle,
    this.mutationStatus = NotificationMutationStatus.idle,
    this.errorMessage,
    this.mutationErrorMessage,
  });

  final NotificationStatus status;
  final List<Notification> notifications;
  final bool hasMore;
  final DateTime? nextCursor;
  final int totalUnread;
  final bool unreadOnly;
  final NotificationLoadMoreStatus loadMoreStatus;
  final NotificationMutationStatus mutationStatus;
  final String? errorMessage;
  final String? mutationErrorMessage;

  bool get hasNotifications => notifications.isNotEmpty;
  bool get canLoadMore =>
      status == NotificationStatus.success &&
      hasMore &&
      nextCursor != null &&
      loadMoreStatus != NotificationLoadMoreStatus.loading;

  NotificationState copyWith({
    NotificationStatus? status,
    List<Notification>? notifications,
    bool? hasMore,
    Object? nextCursor = _unset,
    int? totalUnread,
    bool? unreadOnly,
    NotificationLoadMoreStatus? loadMoreStatus,
    NotificationMutationStatus? mutationStatus,
    Object? errorMessage = _unset,
    Object? mutationErrorMessage = _unset,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: identical(nextCursor, _unset)
          ? this.nextCursor
          : nextCursor as DateTime?,
      totalUnread: totalUnread ?? this.totalUnread,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      mutationErrorMessage: identical(mutationErrorMessage, _unset)
          ? this.mutationErrorMessage
          : mutationErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    hasMore,
    nextCursor,
    totalUnread,
    unreadOnly,
    loadMoreStatus,
    mutationStatus,
    errorMessage,
    mutationErrorMessage,
  ];
}

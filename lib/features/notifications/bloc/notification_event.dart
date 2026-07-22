import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationStarted extends NotificationEvent {
  const NotificationStarted();
}

final class NotificationRefreshed extends NotificationEvent {
  const NotificationRefreshed();
}

final class NotificationFilterChanged extends NotificationEvent {
  const NotificationFilterChanged({required this.unreadOnly});

  final bool unreadOnly;

  @override
  List<Object?> get props => [unreadOnly];
}

final class NotificationLoadMore extends NotificationEvent {
  const NotificationLoadMore();
}

final class NotificationMarkedAsRead extends NotificationEvent {
  const NotificationMarkedAsRead(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationAllMarkedAsRead extends NotificationEvent {
  const NotificationAllMarkedAsRead();
}

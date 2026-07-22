import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class NotificationPage extends Equatable {
  const NotificationPage({
    required this.notifications,
    required this.hasMore,
    required this.nextCursor,
    required this.totalUnread,
  });

  final List<Notification> notifications;
  final bool hasMore;
  final DateTime? nextCursor;
  final int? totalUnread;

  @override
  List<Object?> get props => [notifications, hasMore, nextCursor, totalUnread];
}

class Notification extends Equatable {
  const Notification({
    required this.id,
    required this.recipient,
    required this.title,
    required this.shortContent,
    required this.details,
    required this.sender,
    required this.sentAt,
    required this.isRead,
  });

  final String id;
  final String recipient;
  final String title;
  final String shortContent;
  final String details;
  final String sender;
  final DateTime sentAt;
  final bool isRead;

  factory Notification.fromJson(Map<String, dynamic> json) {
    final id = asString(json['id']) ?? asString(json['_id']);
    final sentAt = asDateTime(json['sentAt']);

    if (id == null || id.isEmpty) {
      throw const FormatException('Notification id is missing.');
    }
    if (sentAt == null) {
      throw const FormatException('Notification sentAt is invalid.');
    }

    return Notification(
      id: id,
      recipient: asString(json['recipient']) ?? '',
      title: asString(json['title']) ?? '',
      shortContent: asString(json['shortContent']) ?? '',
      details: asString(json['details']) ?? '',
      sender: asString(json['sender']) ?? '',
      sentAt: sentAt,
      isRead: asBool(json['isRead']) ?? false,
    );
  }

  Notification copyWith({bool? isRead}) {
    return Notification(
      id: id,
      recipient: recipient,
      title: title,
      shortContent: shortContent,
      details: details,
      sender: sender,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipient,
    title,
    shortContent,
    details,
    sender,
    sentAt,
    isRead,
  ];
}

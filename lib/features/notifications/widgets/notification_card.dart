import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart'
    as notification_entity;
import 'package:ptit_dms_flutter/features/notifications/widgets/notification_date_time_formatter.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final notification_entity.Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Material(
      key: Key('notification_card_${notification.id}'),
      color: unread ? const Color(0xFFFFF4F4) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: unread ? const Color(0xFFF1C9CD) : const Color(0xFFE8E9ED),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: unread
                      ? const Color(0xFFBE1E2D)
                      : const Color(0xFFF0F1F4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  unread
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_none_rounded,
                  color: unread ? Colors.white : const Color(0xFF667085),
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title.isEmpty
                                ? 'Thông báo'
                                : notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF151A2D),
                              fontSize: 15,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor: Color(0xFFBE1E2D),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.shortContent.isNotEmpty
                          ? notification.shortContent
                          : notification.details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Color(0xFF98A0B2),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatNotificationDateTime(notification.sentAt),
                          style: const TextStyle(
                            color: Color(0xFF7D8597),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

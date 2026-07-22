import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart'
    as notification_entity;
import 'package:ptit_dms_flutter/features/notifications/widgets/notification_date_time_formatter.dart';

class NotificationDetailsSheet extends StatelessWidget {
  const NotificationDetailsSheet({super.key, required this.notification});

  final notification_entity.Notification notification;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D8DE),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chi tiết thông báo',
                    style: TextStyle(
                      color: Color(0xFF151A2D),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Đóng',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title.isEmpty
                          ? 'Thông báo'
                          : notification.title,
                      style: const TextStyle(
                        color: Color(0xFF151A2D),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatNotificationDateTime(notification.sentAt),
                      style: const TextStyle(
                        color: Color(0xFF7D8597),
                        fontSize: 13,
                      ),
                    ),
                    if (notification.sender.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Người gửi: ${notification.sender}',
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      notification.details.isNotEmpty
                          ? notification.details
                          : notification.shortContent,
                      style: const TextStyle(
                        color: Color(0xFF343A4A),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/features/notifications/bloc/notification_bloc.dart';

class NotificationToolbar extends StatelessWidget {
  const NotificationToolbar({super.key, required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    final isMutating =
        state.mutationStatus == NotificationMutationStatus.loading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.totalUnread > 0
                      ? '${state.totalUnread} thông báo chưa đọc'
                      : 'Bạn đã đọc tất cả thông báo',
                  style: const TextStyle(
                    color: Color(0xFF4D5567),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                key: const Key('notifications_mark_all_read_button'),
                onPressed: state.totalUnread == 0 || isMutating
                    ? null
                    : () => context.read<NotificationBloc>().add(
                        const NotificationAllMarkedAsRead(),
                      ),
                icon: isMutating
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Đọc tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _NotificationFilterChip(
                key: const Key('notifications_all_filter'),
                label: 'Tất cả',
                selected: !state.unreadOnly,
                onTap: () => context.read<NotificationBloc>().add(
                  const NotificationFilterChanged(unreadOnly: false),
                ),
              ),
              const SizedBox(width: 10),
              _NotificationFilterChip(
                key: const Key('notifications_unread_filter'),
                label: 'Chưa đọc',
                selected: state.unreadOnly,
                badge: state.totalUnread,
                onTap: () => context.read<NotificationBloc>().add(
                  const NotificationFilterChanged(unreadOnly: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationFilterChip extends StatelessWidget {
  const _NotificationFilterChip({
    required super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBE1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFBE1E2D) : const Color(0xFFE1E4EA),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF4D5567),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFF4E7E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFBE1E2D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

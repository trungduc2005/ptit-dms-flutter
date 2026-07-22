import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/features/notifications/bloc/notification_bloc.dart';

class NotificationLoadMoreFooter extends StatelessWidget {
  const NotificationLoadMoreFooter({super.key, required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadMoreStatus == NotificationLoadMoreStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.loadMoreStatus == NotificationLoadMoreStatus.failure) {
      return Center(
        child: TextButton.icon(
          onPressed: () => context.read<NotificationBloc>().add(
            const NotificationLoadMore(),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tải lại'),
        ),
      );
    }

    return const SizedBox(height: 2);
  }
}

class NotificationMessage extends StatelessWidget {
  const NotificationMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFF4E7E9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: const Color(0xFFBE1E2D)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF151A2D),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

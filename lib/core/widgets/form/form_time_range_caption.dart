import 'package:flutter/material.dart';

class FormTimeRangeCaption extends StatelessWidget {
  const FormTimeRangeCaption({
    required this.startTime,
    required this.endTime,
    this.label = 'Thời gian',
    super.key,
  });

  final DateTime? startTime;
  final DateTime? endTime;
  final String label;

  @override
  Widget build(BuildContext context) {
    final start = startTime;
    final end = endTime;
    if (start == null && end == null) {
      return const SizedBox.shrink();
    }

    final value = start != null && end != null
        ? '${_formatDateTime(start)} - ${_formatDateTime(end)}'
        : _formatDateTime(start ?? end!);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_outlined, size: 17, color: Color(0xFF6B7280)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}'
        ' • ${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

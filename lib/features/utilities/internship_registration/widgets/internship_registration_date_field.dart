import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_field_shell.dart';

class InternshipRegistrationDateField extends StatelessWidget {
  const InternshipRegistrationDateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    required this.formatDate,
    super.key,
  });

  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;
  final String Function(DateTime value) formatDate;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Chọn ngày' : formatDate(value!);

    return InternshipRegistrationFieldShell(
      label: label,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: value == null
                      ? const Color(0xFF757575)
                      : const Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF757575),
            ),
          ],
        ),
      ),
    );
  }
}

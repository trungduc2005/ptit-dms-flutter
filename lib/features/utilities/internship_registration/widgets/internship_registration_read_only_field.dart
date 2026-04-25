import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/widgets/internship_registration_field_shell.dart';

class InternshipRegistrationReadOnlyField extends StatelessWidget {
  const InternshipRegistrationReadOnlyField({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '---' : value.trim();

    return InternshipRegistrationFieldShell(
      label: label,
      enabled: false,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          displayValue,
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

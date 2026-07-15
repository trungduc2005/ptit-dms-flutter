import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_field_shell.dart';

/// A read-only display field that shows a value inside a [FormFieldShell].
class FormReadOnlyField extends StatelessWidget {
  const FormReadOnlyField({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '---' : value.trim();

    return FormFieldShell(
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

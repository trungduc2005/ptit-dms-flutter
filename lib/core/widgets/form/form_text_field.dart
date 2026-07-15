import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/widgets/form/form_field_shell.dart';

/// A generic text input form field built on [FormFieldShell].
///
/// For multiline content, set [minLines] and [maxLines] to `null`
/// and provide a [height] that accommodates the desired lines.
class FormTextField extends StatelessWidget {
  const FormTextField({
    required this.label,
    required this.controller,
    required this.enabled,
    super.key,
    this.hintText,
    this.keyboardType,
    this.height = 52,
    this.minLines,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hintText;
  final TextInputType? keyboardType;
  final double height;
  final int? minLines;
  final int? maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines == null || (maxLines != null && maxLines! > 1);

    return FormFieldShell(
      label: label,
      enabled: enabled,
      height: height,
      child: isMultiline
          ? SizedBox.expand(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType ?? TextInputType.multiline,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                textCapitalization: textCapitalization,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            )
          : SizedBox.expand(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: textCapitalization,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
    );
  }
}
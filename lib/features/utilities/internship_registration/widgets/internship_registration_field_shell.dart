import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';

class InternshipRegistrationFieldShell extends StatelessWidget {
  const InternshipRegistrationFieldShell({
    required this.label,
    required this.child,
    super.key,
    this.borderColor,
    this.height = 52,
    this.enabled = true,
  });

  final String label;
  final Widget child;
  final Color? borderColor;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = enabled
        ? const Color(0xFFADACB2)
        : const Color(0xFFADACB2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: resolvedBorderColor, width: 1),
          ),
          child: child,
        ),
      ],
    );
  }
}

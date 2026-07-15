import 'package:flutter/material.dart';

/// A generic section card used in registration forms.
/// Displays a section title followed by the child widget.
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    required this.title,
    required this.child,
    super.key,
    this.bottomPadding = 20,
  });

  final String title;
  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final trimmedTitle = title.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trimmedTitle.isNotEmpty) ...[
            Text(
              trimmedTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

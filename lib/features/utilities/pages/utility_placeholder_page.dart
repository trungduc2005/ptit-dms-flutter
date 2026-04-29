import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_header.dart';

class UtilityPlaceholderPage extends StatelessWidget {
  const UtilityPlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: UtilitiesHeader(title: title, showBackButton: true),
      body: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

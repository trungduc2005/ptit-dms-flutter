import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';

class UtilitiesHeader extends StatelessWidget implements PreferredSizeWidget {
  const UtilitiesHeader({
    required this.title,
    this.showBackButton = false,
    super.key,
  });

  final String title;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: AppTheme.brandColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      title: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

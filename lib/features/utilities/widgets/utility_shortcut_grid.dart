import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';

class UtilityShortcutData {
  const UtilityShortcutData({
    required this.title,
    required this.iconAsset,
    required this.routeName,
  });

  final String title;
  final String iconAsset;
  final String routeName;
}

class UtilityShortcutGrid extends StatelessWidget {
  const UtilityShortcutGrid({
    required this.shortcuts,
    super.key,
  });

  static const int _slotCount = 4;

  final List<UtilityShortcutData> shortcuts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / _slotCount;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_slotCount, (index) {
            if (index >= shortcuts.length) {
              return SizedBox(width: slotWidth);
            }

            return SizedBox(
              width: slotWidth,
              child: UtilityShortcutTile(shortcut: shortcuts[index]),
            );
          }),
        );
      },
    );
  }
}

class UtilityShortcutTile extends StatelessWidget {
  const UtilityShortcutTile({
    required this.shortcut,
    super.key,
  });

  final UtilityShortcutData shortcut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(shortcut.routeName),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE6E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    shortcut.iconAsset,
                    width: 36,
                    height: 36,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.brandColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                shortcut.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

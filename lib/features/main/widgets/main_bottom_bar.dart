import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/main/models/main_tab.dart';

class MainBottomBar extends StatelessWidget {
  const MainBottomBar({
    required this.currentTab,
    required this.onSelected,
    super.key,
  });

  final MainTab currentTab;
  final ValueChanged<MainTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;

    final selectedColor =
        navTheme.selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor =
        navTheme.unselectedItemColor ?? theme.unselectedWidgetColor;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentTab.index,
      onTap: (index) => onSelected(MainTab.values[index]),
      items: MainTab.values
          .map(
            (tab) => BottomNavigationBarItem(
              icon: tab.buildIcon(unselectedColor),
              activeIcon: tab.buildIcon(selectedColor),
              label: tab.label,
            ),
          )
          .toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/main/models/main_tab.dart';
import 'package:ptit_dms_flutter/features/main/navigation/main_tab_routes.dart';

class MainTabNavigator extends StatelessWidget {
  const MainTabNavigator({
    required this.tab,
    required this.navigatorKey,
    required this.observer,
    super.key,
  });

  final MainTab tab;
  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorObserver observer;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: <NavigatorObserver>[observer],
      onGenerateRoute: (settings) {
        return MainTabRoutes.onGenerateRoute(tab, settings);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/home/pages/home_page.dart';
import 'package:ptit_dms_flutter/features/main/models/main_tab.dart';
import 'package:ptit_dms_flutter/features/main/pages/main_tab_child_page.dart';
import 'package:ptit_dms_flutter/features/notifications/notifications_page.dart';
import 'package:ptit_dms_flutter/features/profile/pages/profile_page.dart';
import 'package:ptit_dms_flutter/features/utilities/pages/utilities_page.dart';

class MainTabRoutes {
  static Route<dynamic> onGenerateRoute(MainTab tab, RouteSettings settings) {
    final routeName = settings.name ?? Navigator.defaultRouteName;

    switch (routeName) {
      case Navigator.defaultRouteName:
      case '/':
        return MaterialPageRoute(
          builder: (_) => _buildRootPage(tab),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => MainTabChildPage(title: '${tab.label} - $routeName'),
          settings: settings,
        );
    }
  }

  static Widget _buildRootPage(MainTab tab) {
    switch (tab) {
      case MainTab.home:
        return const HomePage();
      case MainTab.utilities:
        return const UtilitiesPage();
      case MainTab.notifications:
        return const NotificationsPage();
      case MainTab.profile:
        return const ProfilePage();
    }
  }
}

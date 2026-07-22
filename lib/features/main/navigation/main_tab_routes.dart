import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/home/pages/home_page.dart';
import 'package:ptit_dms_flutter/features/main/models/main_tab.dart';
import 'package:ptit_dms_flutter/features/main/pages/main_tab_child_page.dart';
import 'package:ptit_dms_flutter/features/notifications/notifications_page.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/features/profile/navigation/profile_routes.dart';
import 'package:ptit_dms_flutter/features/profile/pages/account_information_page.dart';
import 'package:ptit_dms_flutter/features/profile/pages/profile_page.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_router.dart';

class MainTabRoutes {
  static Route<dynamic> onGenerateRoute(MainTab tab, RouteSettings settings) {
    switch (tab) {
      case MainTab.home:
        return _buildSimpleTabRoute(
          settings: settings,
          tab: tab,
          rootPage: const HomePage(),
        );
      case MainTab.utilities:
        return UtilitiesRouter.onGenerateRoute(settings);
      case MainTab.notifications:
        return _buildSimpleTabRoute(
          settings: settings,
          tab: tab,
          rootPage: const NotificationsPage(),
        );
      case MainTab.profile:
        return _buildProfileRoute(settings);
    }
  }

  static Route<dynamic> _buildProfileRoute(RouteSettings settings) {
    final routeName = settings.name ?? Navigator.defaultRouteName;

    switch (routeName) {
      case Navigator.defaultRouteName:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case ProfileRoutes.accountInformation:
        final profile = settings.arguments;
        if (profile is StudentProfile) {
          return MaterialPageRoute<bool>(
            builder: (_) => AccountInformationPage(profile: profile),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const MainTabChildPage(
            title: 'Không tìm thấy thông tin tài khoản',
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => MainTabChildPage(title: 'Hồ sơ - $routeName'),
          settings: settings,
        );
    }
  }

  static Route<dynamic> _buildSimpleTabRoute({
    required RouteSettings settings,
    required MainTab tab,
    required Widget rootPage,
  }) {
    final routeName = settings.name ?? Navigator.defaultRouteName;

    switch (routeName) {
      case Navigator.defaultRouteName:
        return MaterialPageRoute(builder: (_) => rootPage, settings: settings);
      default:
        return MaterialPageRoute(
          builder: (_) => MainTabChildPage(title: '${tab.label} - $routeName'),
          settings: settings,
        );
    }
  }
}

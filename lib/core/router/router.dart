import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/auth/pages/login_page.dart';
import 'package:ptit_dms_flutter/features/auth/pages/splash_page.dart';
import 'package:ptit_dms_flutter/features/main/pages/main_shell_page.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainShellPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MainTab { home, utilities, notifications, profile }

extension MainTabX on MainTab {
  String get label {
    switch (this) {
      case MainTab.home:
        return 'Trang chủ';
      case MainTab.utilities:
        return 'Tiện ích';
      case MainTab.notifications:
        return 'Thông báo';
      case MainTab.profile:
        return 'Cá nhân';
    }
  }

  String get assetPath {
    switch (this) {
      case MainTab.home:
        return 'assets/icons/home.svg';
      case MainTab.utilities:
        return 'assets/icons/utilities.svg';
      case MainTab.notifications:
      return 'assets/icons/notification.svg';
      case MainTab.profile:
      return 'assets/icons/profile.svg';
    }
  }

  Widget buildIcon(Color color){
    return SvgPicture.asset(
      assetPath, width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

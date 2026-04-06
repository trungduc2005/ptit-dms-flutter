import 'package:flutter/widgets.dart';

class TabNavigationObserver extends NavigatorObserver {
  TabNavigationObserver({required this.onStackChanged});

  final VoidCallback onStackChanged;

  void _notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onStackChanged();
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notify();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _notify();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify();
  }
}

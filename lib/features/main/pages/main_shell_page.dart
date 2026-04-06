import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/main/models/main_tab.dart';
import 'package:ptit_dms_flutter/features/main/navigation/tab_navigation_observer.dart';
import 'package:ptit_dms_flutter/features/main/widgets/main_bottom_bar.dart';
import 'package:ptit_dms_flutter/features/main/widgets/main_tab_navigator.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late final Map<MainTab, GlobalKey<NavigatorState>> _navigatorKeys;
  late final Map<MainTab, TabNavigationObserver> _observers;
  late final Map<MainTab, bool> _tabCanPop;

  MainTab _currentTab = MainTab.home;

  @override
  void initState() {
    super.initState();

    _navigatorKeys = {
      for (final tab in MainTab.values) tab: GlobalKey<NavigatorState>(),
    };

    _tabCanPop = {for (final tab in MainTab.values) tab: false};

    _observers = {
      for (final tab in MainTab.values)
        tab: TabNavigationObserver(
          onStackChanged: () => (_syncCanPopState(tab)),
        ),
    };
  }

  bool get _showBottomBar => !(_tabCanPop[_currentTab] ?? false);

  void _syncCanPopState(MainTab tab) {
    final canPop = _navigatorKeys[tab]!.currentState?.canPop() ?? false;

    if (!mounted || _tabCanPop[tab] == canPop) {
      return;
    }

    setState(() {
      _tabCanPop[tab] = canPop;
    });
  } 

  void _onTabSelected(MainTab tab) {
    if (tab == _currentTab) {
      _navigatorKeys[tab]!.currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _currentTab = tab;
    });
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentTab]!.currentState;

    if (currentNavigator?.canPop() ?? false) {
      currentNavigator!.pop();
      return false;
    }

    if (_currentTab != MainTab.home) {
      setState(() {
        _currentTab = MainTab.home;
      });
      return false;
    }

    return true;
  }

  void _handleAuthChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.unauthenticated) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _handleAuthChanged,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: IndexedStack(
            index: _currentTab.index,
            children: MainTab.values
                .map(
                  (tab) => MainTabNavigator(
                    tab: tab,
                    navigatorKey: _navigatorKeys[tab]!,
                    observer: _observers[tab]!,
                  ),
                )
                .toList(),
          ),
          bottomNavigationBar: _showBottomBar
              ? MainBottomBar(
                  currentTab: _currentTab,
                  onSelected: _onTabSelected,
                )
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/main/models/main_tab.dart';
import 'package:ptit_dms_flutter/features/main/navigation/tab_navigation_observer.dart';
import 'package:ptit_dms_flutter/features/main/widgets/main_bottom_bar.dart';
import 'package:ptit_dms_flutter/features/main/widgets/main_tab_navigator.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/required_profile_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/required_profile_dialog.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late final Map<MainTab, GlobalKey<NavigatorState>> _navigatorKeys;
  late final Map<MainTab, TabNavigationObserver> _observers;
  late final Map<MainTab, bool> _tabCanPop;
  late final RequiredProfileBloc _requiredProfileBloc;

  MainTab _currentTab = MainTab.home;
  bool _isRequiredProfileDialogOpen = false;

  @override
  void initState() {
    super.initState();

    _requiredProfileBloc = RequiredProfileBloc(
      context.read<StudentProfileRepository>(),
    );

    _navigatorKeys = {
      for (final tab in MainTab.values) tab: GlobalKey<NavigatorState>(),
    };

    _tabCanPop = {
      for (final tab in MainTab.values) tab: false,
    };

    _observers = {
      for (final tab in MainTab.values)
        tab: TabNavigationObserver(
          onStackChanged: () => _syncCanPopState(tab),
        ),
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requiredProfileBloc.add(const RequiredProfileStarted());
    });
  }

  @override
  void dispose() {
    _requiredProfileBloc.close();
    super.dispose();
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

  Future<void> _showRequiredProfileDialog() async {
    if (!mounted || _isRequiredProfileDialogOpen) {
      return;
    }

    _isRequiredProfileDialogOpen = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.26),
      builder: (_) {
        return BlocProvider.value(
          value: _requiredProfileBloc,
          child: const RequiredProfileDialog(),
        );
      },
    );

    if (!mounted) {
      return;
    }

    _isRequiredProfileDialogOpen = false;
  }

  void _handleAuthChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.unauthenticated) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  void _handleRequiredProfileChanged(
    BuildContext context,
    RequiredProfileState state,
  ) {
    if (state.status == RequiredProfileStatus.incomplete) {
      _showRequiredProfileDialog();
      return;
    }

    if (state.status == RequiredProfileStatus.success &&
        _isRequiredProfileDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cap nhat thong tin thanh cong.'),
        ),
      );
      return;
    }

    if (state.status == RequiredProfileStatus.failure &&
        state.requirement == null &&
        (state.message?.trim().isNotEmpty ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _requiredProfileBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: _handleAuthChanged,
          ),
          BlocListener<RequiredProfileBloc, RequiredProfileState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: _handleRequiredProfileChanged,
          ),
        ],
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
      ),
    );
  }
}

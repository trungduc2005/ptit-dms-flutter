import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_popup_dialog.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/main/pages/main_tab_child_page.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/profile_context_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/profile_view_body.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileContextBloc(
        context.read<StudentProfileRepository>(),
      )..add(const ProfileContextStarted()),
      child: const _ProfilePageView(),
    );
  }
}

class _ProfilePageView extends StatefulWidget {
  const _ProfilePageView();

  @override
  State<_ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<_ProfilePageView> {
  bool _isPopupOpen = false;

  void _refresh() {
    context.read<ProfileContextBloc>().add(const ProfileContextRefreshed());
  }

  void _openAccountInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MainTabChildPage(
          title: 'Thong tin tai khoan',
        ),
      ),
    );
  }

  Future<T?> _showPopup<T>({
    required Widget Function(BuildContext dialogContext) builder,
  }) async {
    if (!mounted || _isPopupOpen) {
      return null;
    }

    _isPopupOpen = true;

    final result = await showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: builder,
    );

    if (!mounted) {
      return result;
    }

    _isPopupOpen = false;
    return result;
  }

  Future<void> _confirmLogout() async {
    final confirmed = await _showPopup<bool>(
      builder: (dialogContext) {
        return AppPopupDialog(
          title: 'Đăng xuất',
          message: 'Bạn có chắc chắn muốn đăng xuất không?',
          secondaryLabel: 'Hủy',
          primaryLabel: 'Đăng xuất',
          onSecondaryPressed: () {
            Navigator.of(dialogContext).pop(false);
          },
          onPrimaryPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  Future<void> _showErrorDialog(String message) async {
    await _showPopup<void>(
      builder: (dialogContext) {
        return AppPopupDialog(
          title: 'Thông báo',
          message: message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFFF8F8F8)),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SafeArea(
            child: BlocListener<ProfileContextBloc, ProfileContextState>(
              listenWhen: (previous, current) {
                return previous.status != current.status &&
                    current.status == ProfileContextStatus.failure &&
                    (current.errorMessage?.trim().isNotEmpty ?? false);
              },
              listener: (context, state) {
                _showErrorDialog(
                  state.errorMessage ?? 'Da xay ra loi.',
                );
              },
              child: BlocBuilder<ProfileContextBloc, ProfileContextState>(
                builder: (context, state) {
                  return ProfileViewBody(
                    state: state,
                    onRetry: _refresh,
                    onAccountInfoTap: _openAccountInfo,
                    onLogoutTap: _confirmLogout,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

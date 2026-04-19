import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/profile_context_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/profile_action_tile.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/profile_header_section.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/profile_logout_action.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({
    required this.state,
    required this.onRetry,
    required this.onAccountInfoTap,
    required this.onLogoutTap,
    super.key,
  });

  final ProfileContextState state;
  final VoidCallback onRetry;
  final VoidCallback onAccountInfoTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;

    if (state.status == ProfileContextStatus.loading && profile == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: Color(0xFF98A2B3),
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Khong the tai du lieu ca nhan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Thu lai',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeaderSection(profile: profile),
              Transform.translate(
                offset: const Offset(0, -34),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileActionTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Thông tin tài khoản',
                            onTap: onAccountInfoTap,
                          ),
                          const SizedBox(height: 28),
                          ProfileLogoutAction(onTap: onLogoutTap),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.status == ProfileContextStatus.loading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/profile_submit_bloc.dart';
import 'package:ptit_dms_flutter/features/profile/widgets/account_information_form.dart';

class AccountInformationPage extends StatelessWidget {
  const AccountInformationPage({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileSubmitBloc(context.read<StudentProfileRepository>()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          title: const Text(
            'Thông tin tài khoản',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppTheme.brandColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: AccountInformationForm(profile: profile),
      ),
    );
  }
}

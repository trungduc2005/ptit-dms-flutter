import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_section_card.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utility_shortcut_grid.dart';

class UtilitiesPage extends StatelessWidget {
  const UtilitiesPage({super.key});

  static const List<UtilityShortcutData> _internshipShortcuts = [
    UtilityShortcutData(
      title: 'Doanh\nnghiệp',
      iconAsset: 'assets/icons/company.svg',
      routeName: UtilitiesRoutes.companies,
    ),
    UtilityShortcutData(
      title: 'Đăng ký\nthực tập',
      iconAsset: 'assets/icons/register.svg',
      routeName: UtilitiesRoutes.internshipRegistration,
    ),
    // UtilityShortcutData(
    //   title: 'Kết quả\nđăng ký',
    //   iconAsset: 'assets/icons/result.svg',
    //   routeName: UtilitiesRoutes.registrationResult,
    // ),
  ];

  static const List<UtilityShortcutData> _researchShortcuts = [
    UtilityShortcutData(
      title: 'Đăng ký\nnghiên cứu',
      iconAsset: 'assets/icons/research.svg',
      routeName: UtilitiesRoutes.researchRegistration,
    ),
    UtilityShortcutData(
      title: 'BC trước\nnghiệm thu',
      iconAsset: 'assets/icons/research_pre_acceptance_report.svg',
      routeName: UtilitiesRoutes.researchPreAcceptanceReport,
    ),
    UtilityShortcutData(
      title: 'BC sau\nnghiệm thu',
      iconAsset: 'assets/icons/research_post_acceptance_report.svg',
      routeName: UtilitiesRoutes.researchPostAcceptanceReport,
    ),
    UtilityShortcutData(
      title: 'Hội đồng\nhội thảo',
      iconAsset: 'assets/icons/committee.svg',
      routeName: UtilitiesRoutes.researchSeminarCommittee,
    ),
    UtilityShortcutData(
      title: 'Hội đồng\nnghiệm thu',
      iconAsset: 'assets/icons/committee.svg',
      routeName: UtilitiesRoutes.researchFinalCommittee,
    ),
  ];

  static const List<UtilityShortcutData> _projectShortcuts = [
    UtilityShortcutData(
      title: 'Đăng ký\nđồ án',
      iconAsset: 'assets/icons/project.svg',
      routeName: UtilitiesRoutes.projectRegistration,
    ),
    UtilityShortcutData(
      title: 'Thông tin\nhội đồng',
      iconAsset: 'assets/icons/committee.svg',
      routeName: UtilitiesRoutes.projectCommittee,
    ),
    UtilityShortcutData(
      title: 'Báo cáo\ntiến độ',
      iconAsset: 'assets/icons/progression.svg',
      routeName: UtilitiesRoutes.projectProgressReport,
    ),
    UtilityShortcutData(
      title: 'Nộp trước\nbảo vệ',
      iconAsset: 'assets/icons/project_pre_defense_submission.svg',
      routeName: UtilitiesRoutes.projectPreDefenseSubmission,
    ),
    UtilityShortcutData(
      title: 'Nộp sau\nbảo vệ',
      iconAsset: 'assets/icons/project_post_defense_submission.svg',
      routeName: UtilitiesRoutes.projectPostDefenseSubmission,
    ),
    UtilityShortcutData(
      title: 'Kết quả\nđồ án',
      iconAsset: 'assets/icons/project_result.svg',
      routeName: UtilitiesRoutes.projectResult,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final role = context.select<AuthBloc, String?>((bloc) => bloc.state.role);
    final isLecturer = role == 'lecturer';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AppHeader(title: 'Tiện ích'),
      body: isLecturer ? _buildLecturerEmptyState() : _buildStudentUtilities(),
    );
  }

  Widget _buildStudentUtilities() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          UtilitiesSectionCard(
            title: 'Thực tập',
            child: UtilityShortcutGrid(shortcuts: _internshipShortcuts),
          ),
          SizedBox(height: 16),
          UtilitiesSectionCard(
            title: 'Đồ án',
            child: UtilityShortcutGrid(shortcuts: _projectShortcuts),
          ),
          SizedBox(height: 16),
          UtilitiesSectionCard(
            title: 'Nghiên cứu khoa học',
            child: UtilityShortcutGrid(shortcuts: _researchShortcuts),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturerEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFBDBDBD)),
            SizedBox(height: 16),
            Text(
              'Không có tiện ích khả dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tài khoản giảng viên hiện chưa có tiện ích trên ứng dụng di động. '
              'Vui lòng đăng nhập trên hệ thống website để thực hiện các nghiệp vụ quản lý.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

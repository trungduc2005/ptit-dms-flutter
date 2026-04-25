import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';
import 'package:ptit_dms_flutter/features/utilities/widgets/utilities_header.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const UtilitiesHeader(title: 'Tiện ích'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 20,
        ),
        child: const UtilitiesSectionCard(
          title: 'Thực tập',
          child: UtilityShortcutGrid(
            shortcuts: _internshipShortcuts,
          ),
        ),
      ),
    );
  }
}

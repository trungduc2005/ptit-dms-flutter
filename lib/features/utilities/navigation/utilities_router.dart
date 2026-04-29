import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/pages/companies_page.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/pages/company_detail_page.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';
import 'package:ptit_dms_flutter/features/utilities/pages/internship_registration_page.dart';
import 'package:ptit_dms_flutter/features/utilities/pages/utilities_page.dart';
import 'package:ptit_dms_flutter/features/utilities/pages/utility_placeholder_page.dart';

class UtilitiesRouter {
  UtilitiesRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? Navigator.defaultRouteName;

    switch (routeName) {
      case Navigator.defaultRouteName:
        return MaterialPageRoute(
          builder: (_) => const UtilitiesPage(),
          settings: settings,
        );
      case UtilitiesRoutes.companies:
        return MaterialPageRoute(
          builder: (_) => const CompaniesPage(),
          settings: settings,
        );
      case UtilitiesRoutes.companyDetail:
        final company = settings.arguments;
        return MaterialPageRoute(
          builder: (_) {
            if (company is Company) {
              return CompanyDetailPage(company: company);
            }

            return const UtilityPlaceholderPage(title: 'Chi tiết doanh nghiệp');
          },
          settings: settings,
        );
      case UtilitiesRoutes.internshipRegistration:
        return MaterialPageRoute(
          builder: (_) => const InternshipRegistrationPage(),
          settings: settings,
        );
      case UtilitiesRoutes.registrationResult:
        return MaterialPageRoute(
          builder: (_) =>
              const UtilityPlaceholderPage(title: 'Kết quả đăng ký'),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => UtilityPlaceholderPage(title: routeName),
          settings: settings,
        );
    }
  }
}

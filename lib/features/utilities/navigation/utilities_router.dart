import 'package:flutter/material.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/pages/companies_page.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/pages/company_detail_page.dart';
import 'package:ptit_dms_flutter/features/utilities/navigation/utilities_routes.dart';
import 'package:ptit_dms_flutter/features/utilities/internship_registration/pages/internship_registration_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_committee/pages/project_committee_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_post_defense_submission/pages/project_post_defense_submission_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_pre_defense_submission/pages/project_pre_defense_submission_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_progress_report/pages/project_progress_report_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/pages/project_registration_page.dart';
import 'package:ptit_dms_flutter/features/utilities/project_result/pages/project_result_page.dart';
import 'package:ptit_dms_flutter/features/utilities/research_post_acceptance_report/pages/research_post_acceptance_report_page.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/pages/research_pre_acceptance_report_page.dart';
import 'package:ptit_dms_flutter/features/utilities/research_registration/pages/research_registration_page.dart';
import 'package:ptit_dms_flutter/features/utilities/research_seminar_committee/pages/research_seminar_committee_page.dart';
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
      case UtilitiesRoutes.projectRegistration:
        return MaterialPageRoute(
          builder: (_) => const ProjectRegistrationPage(),
          settings: settings,
        );
      case UtilitiesRoutes.researchRegistration:
        return MaterialPageRoute(
          builder: (_) => const ResearchRegistrationPage(),
          settings: settings,
        );
      case UtilitiesRoutes.researchPreAcceptanceReport:
        return MaterialPageRoute(
          builder: (_) => const ResearchPreAcceptanceReportPage(),
          settings: settings,
        );
      case UtilitiesRoutes.researchPostAcceptanceReport:
        return MaterialPageRoute(
          builder: (_) => const ResearchPostAcceptanceReportPage(),
          settings: settings,
        );
      case UtilitiesRoutes.researchSeminarCommittee:
        return MaterialPageRoute(
          builder: (_) => const ResearchSeminarCommitteePage(),
          settings: settings,
        );
      case UtilitiesRoutes.projectCommittee:
        return MaterialPageRoute(
          builder: (_) => const ProjectCommitteePage(),
          settings: settings,
        );
      case UtilitiesRoutes.projectProgressReport:
        return MaterialPageRoute(
          builder: (_) => const ProjectProgressReportPage(),
          settings: settings,
        );
      case UtilitiesRoutes.projectPreDefenseSubmission:
        return MaterialPageRoute(
          builder: (_) => const ProjectPreDefenseSubmissionPage(),
          settings: settings,
        );
      case UtilitiesRoutes.projectPostDefenseSubmission:
        return MaterialPageRoute(
          builder: (_) => const ProjectPostDefenseSubmissionPage(),
          settings: settings,
        );
      case UtilitiesRoutes.projectResult:
        return MaterialPageRoute(
          builder: (_) => const ProjectResultPage(),
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

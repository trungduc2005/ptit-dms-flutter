import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/router/router.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_bloc.dart';

class App extends StatelessWidget {
  const App({
    required this.authRepository,
    required this.studentProfileRepository,
    required this.academicYearRepository,
    required this.eligibilityRepository,
    required this.timelineRepository,
    required this.companyRepository,
    required this.internCvRepository,
    required this.internRegistrationRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final StudentProfileRepository studentProfileRepository;
  final AcademicYearRepository academicYearRepository;
  final EligibilityRepository eligibilityRepository;
  final TimelineRepository timelineRepository;
  final CompanyRepository companyRepository;
  final InternCvRepository internCvRepository;
  final InternRegistrationRepository internRegistrationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<StudentProfileRepository>.value(
          value: studentProfileRepository,
        ),
        RepositoryProvider<AcademicYearRepository>.value(
          value: academicYearRepository,
        ),
        RepositoryProvider<EligibilityRepository>.value(
          value: eligibilityRepository,
        ),
        RepositoryProvider<TimelineRepository>.value(
          value: timelineRepository,
        ),
        RepositoryProvider<CompanyRepository>.value(value: companyRepository),
        RepositoryProvider<InternCvRepository>.value(value: internCvRepository),
        RepositoryProvider<InternRegistrationRepository>.value(
          value: internRegistrationRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: '/',
        ),
      ),
    );
  }
}

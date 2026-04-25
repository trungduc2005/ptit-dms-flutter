import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/academic_year_remote_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/company_remote_data_source.dart';
import 'data/datasources/eligibility_remote_data_source.dart';
import 'data/datasources/intern_cv_remote_data_source.dart';
import 'data/datasources/intern_registration_remote_data_source.dart';
import 'data/datasources/student_profile_remote_data_source.dart';
import 'data/datasources/timeline_remote_data_source.dart';
import 'data/repositories/academic_year_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/company_repository_impl.dart';
import 'data/repositories/eligibility_repository_impl.dart';
import 'data/repositories/intern_cv_repository_impl.dart';
import 'data/repositories/intern_registration_repository_impl.dart';
import 'data/repositories/student_profile_repository_impl.dart';
import 'data/repositories/timeline_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();

  final cookieJar = PersistCookieJar(
    ignoreExpires: false,
    storage: FileStorage('${directory.path}/.cookies/'),
  );

  final dio = createDioClient(cookieJar);

  final authRepository = AuthRepositoryImpl(
    AuthRemoteDataSource(dio),
    cookieJar,
  );

  final studentProfileRepository = StudentProfileRepositoryImpl(
    StudentProfileRemoteDataSource(dio),
  );

  final academicYearRepository = AcademicYearRepositoryImpl(
    AcademicYearRemoteDataSource(dio),
  );

  final eligibilityRepository = EligibilityRepositoryImpl(
    EligibilityRemoteDataSource(dio),
  );

  final timelineRepository = TimelineRepositoryImpl(
    TimelineRemoteDataSource(dio),
  );

  final companyRepository = CompanyRepositoryImpl(
    CompanyRemoteDataSource(dio),
  );

  final internCvRepository = InternCvRepositoryImpl(
    InternCvRemoteDataSource(dio),
  );

  final internRegistrationRepository = InternRegistrationRepositoryImpl(
    InternRegistrationRemoteDataSource(dio),
  );

  runApp(
    App(
      authRepository: authRepository,
      studentProfileRepository: studentProfileRepository,
      academicYearRepository: academicYearRepository,
      eligibilityRepository: eligibilityRepository,
      timelineRepository: timelineRepository,
      companyRepository: companyRepository,
      internCvRepository: internCvRepository,
      internRegistrationRepository: internRegistrationRepository,
    ),
  );
}

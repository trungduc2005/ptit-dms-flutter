import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ptit_dms_flutter/core/network/dio_client.dart';
import 'package:ptit_dms_flutter/data/datasources/academic_year_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/company_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/eligibility_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_cv_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_registration_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/student_profile_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/student_search_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/datasources/timeline_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/academic_year_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/auth_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/company_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/eligibility_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/intern_cv_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/intern_registration_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/student_profile_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/student_search_repository_impl.dart';
import 'package:ptit_dms_flutter/data/repositories/timeline_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_search_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.studentProfileRepository,
    required this.academicYearRepository,
    required this.eligibilityRepository,
    required this.timelineRepository,
    required this.companyRepository,
    required this.internCvRepository,
    required this.internRegistrationRepository,
    required this.studentSearchRepository,
  });

  final AuthRepository authRepository;
  final StudentProfileRepository studentProfileRepository;
  final AcademicYearRepository academicYearRepository;
  final EligibilityRepository eligibilityRepository;
  final TimelineRepository timelineRepository;
  final CompanyRepository companyRepository;
  final InternCvRepository internCvRepository;
  final InternRegistrationRepository internRegistrationRepository;
  final StudentSearchRepository studentSearchRepository;

  static Future<AppDependencies> create() async {
    final directory = await getApplicationDocumentsDirectory();

    final cookieJar = PersistCookieJar(
      ignoreExpires: false,
      storage: FileStorage('${directory.path}/.cookies/'),
    );

    final dio = createDioClient(cookieJar);

    return AppDependencies(
      authRepository: AuthRepositoryImpl(AuthRemoteDataSource(dio), cookieJar),
      studentProfileRepository: StudentProfileRepositoryImpl(
        StudentProfileRemoteDataSource(dio),
      ),
      academicYearRepository: AcademicYearRepositoryImpl(
        AcademicYearRemoteDataSource(dio),
      ),
      eligibilityRepository: EligibilityRepositoryImpl(
        EligibilityRemoteDataSource(dio),
      ),
      timelineRepository: TimelineRepositoryImpl(TimelineRemoteDataSource(dio)),
      companyRepository: CompanyRepositoryImpl(CompanyRemoteDataSource(dio)),
      internCvRepository: InternCvRepositoryImpl(InternCvRemoteDataSource(dio)),
      internRegistrationRepository: InternRegistrationRepositoryImpl(
        InternRegistrationRemoteDataSource(dio),
      ),
      studentSearchRepository: StudentSearchRepositoryImpl(
        StudentSearchRemoteDataSource(dio),
      ),
    );
  }
}

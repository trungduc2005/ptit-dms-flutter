import 'package:ptit_dms_flutter/domain/entities/current_intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_check.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_cv_download.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_request.dart';

abstract class InternRegistrationRepository {
  Future<InternRegistration> registerInternship({
    required InternRegistrationRequest request,
  });

  Future<InternRegistration> updateInternship({
    required InternRegistrationRequest request,
  });

  Future<CurrentInternRegistration?> getCurrentRegistration({
    required String academicYearId,
  });

  Future<InternRegistrationCheck> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  });

  Future<InternRegistrationCvDownload> downloadRegistrationCv({
    required String studentId,
    required String academicYearId,
  });
}

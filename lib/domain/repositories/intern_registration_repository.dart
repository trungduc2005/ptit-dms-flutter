import 'package:ptit_dms_flutter/data/models/current_intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_check_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_cv_download_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';

abstract class InternRegistrationRepository {
  Future<InternRegistrationModel> registerInternship({
    required InternRegistrationRequestModel request,
  });

  Future<InternRegistrationModel> updateInternship({
    required InternRegistrationRequestModel request,
  });

  Future<CurrentInternRegistrationModel?> getCurrentRegistration({
    required String academicYearId,
  });

  Future<InternRegistrationCheckModel> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  });

  Future<InternRegistrationCvDownloadModel> downloadRegistrationCv({
    required String studentId,
    required String academicYearId,
  });
}

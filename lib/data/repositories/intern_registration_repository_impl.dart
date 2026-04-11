import 'package:ptit_dms_flutter/data/datasources/intern_registration_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/current_intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_check_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_cv_download_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';

class InternRegistrationRepositoryImpl implements InternRegistrationRepository {
  InternRegistrationRepositoryImpl(this._remoteDataSource);

  final InternRegistrationRemoteDataSource _remoteDataSource;

  @override
  Future<InternRegistrationModel> registerInternship({
    required InternRegistrationRequestModel request,
  }) {
    return _remoteDataSource.registerInternship(request: request);
  }

  @override
  Future<InternRegistrationModel> updateInternship({
    required InternRegistrationRequestModel request,
  }) {
    return _remoteDataSource.updateInternship(request: request);
  }

  @override
  Future<CurrentInternRegistrationModel?> getCurrentRegistration({
    required String academicYearId,
  }) {
    return _remoteDataSource.getCurrentRegistration(
      academicYearId: academicYearId,
    );
  }

  @override
  Future<InternRegistrationCheckModel> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  }) {
    return _remoteDataSource.checkInternRegistration(
      studentId: studentId,
      academicYearId: academicYearId,
    );
  }

  @override
  Future<InternRegistrationCvDownloadModel> downloadRegistrationCv({
    required String studentId,
    required String academicYearId,
  }) {
    return _remoteDataSource.downloadRegistrationCv(
      studentId: studentId,
      academicYearId: academicYearId,
    );
  }
}

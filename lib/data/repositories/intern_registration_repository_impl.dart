import 'package:ptit_dms_flutter/data/datasources/intern_registration_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/current_intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_check.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_cv_download.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';

class InternRegistrationRepositoryImpl implements InternRegistrationRepository {
  InternRegistrationRepositoryImpl(this._remoteDataSource);

  final InternRegistrationRemoteDataSource _remoteDataSource;

  @override
  Future<InternRegistration> registerInternship({
    required InternRegistrationRequest request,
  }) {
    return _remoteDataSource.registerInternship(request: request);
  }

  @override
  Future<InternRegistration> updateInternship({
    required InternRegistrationRequest request,
  }) {
    return _remoteDataSource.updateInternship(request: request);
  }

  @override
  Future<CurrentInternRegistration?> getCurrentRegistration({
    required String academicYearId,
  }) {
    return _remoteDataSource.getCurrentRegistration(
      academicYearId: academicYearId,
    );
  }

  @override
  Future<InternRegistrationCheck> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  }) {
    return _remoteDataSource.checkInternRegistration(
      studentId: studentId,
      academicYearId: academicYearId,
    );
  }

  @override
  Future<InternRegistrationCvDownload> downloadRegistrationCv({
    required String studentId,
    required String academicYearId,
  }) {
    return _remoteDataSource.downloadRegistrationCv(
      studentId: studentId,
      academicYearId: academicYearId,
    );
  }
}

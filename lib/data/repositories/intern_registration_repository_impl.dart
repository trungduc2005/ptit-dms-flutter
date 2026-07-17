import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_registration_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/current_intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_check.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_cv_download.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';

class InternRegistrationRepositoryImpl implements InternRegistrationRepository {
  InternRegistrationRepositoryImpl(this._remoteDataSource, this._mapper);

  final InternRegistrationRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<InternRegistration> registerInternship({
    required InternRegistrationRequest request,
  }) async {
    try {
      return await _remoteDataSource.registerInternship(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<InternRegistration> updateInternship({
    required InternRegistrationRequest request,
  }) async {
    try {
      return await _remoteDataSource.updateInternship(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<CurrentInternRegistration?> getCurrentRegistration({
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getCurrentRegistration(
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<InternRegistrationCheck> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.checkInternRegistration(
        studentId: studentId,
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<InternRegistrationCvDownload> downloadRegistrationCv({
    required String studentId,
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.downloadRegistrationCv(
        studentId: studentId,
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}
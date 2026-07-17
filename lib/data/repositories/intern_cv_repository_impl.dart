import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_cv_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_accepted_company_proof.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_cv_upload_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';

class InternCvRepositoryImpl implements InternCvRepository {
  InternCvRepositoryImpl(this._remoteDataSource, this._mapper);

  final InternCvRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<InternCvUploadResult> uploadCv({
    required String academicYearId,
    required String filePath,
    String? studentId,
  }) async {
    try {
      return await _remoteDataSource.uploadCv(
        academicYearId: academicYearId,
        filePath: filePath,
        studentId: studentId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<InternRegistrationEvidenceUploadResult> uploadAcceptedCompanyEvidence({
    required String academicYearId,
    required String filePath,
  }) async {
    try {
      return await _remoteDataSource.uploadAcceptedCompanyEvidence(
        academicYearId: academicYearId,
        filePath: filePath,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}
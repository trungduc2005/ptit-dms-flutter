import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_pre_defense_submission_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_pre_defense_submission_repository.dart';

class ProjectPreDefenseSubmissionRepositoryImpl
    implements ProjectPreDefenseSubmissionRepository {
  ProjectPreDefenseSubmissionRepositoryImpl(
    this._remoteDataSource,
    this._mapper,
  );

  final ProjectPreDefenseSubmissionRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<ProjectPreDefenseSubmission> getSubmission({
    required String projectId,
    required String academicYearId,
  }) {
    return _guard(
      () => _remoteDataSource.getSubmission(
        projectId: projectId,
        academicYearId: academicYearId,
      ),
      invalidDataMessage: 'Dữ liệu nộp đồ án trước bảo vệ không hợp lệ.',
    );
  }

  @override
  Future<void> uploadSubmission({
    required ProjectPreDefenseSubmissionRequest request,
    ProjectUploadProgressCallback? onSendProgress,
  }) {
    return _guard(
      () => _remoteDataSource.uploadSubmission(
        request: request,
        onSendProgress: onSendProgress,
      ),
      invalidDataMessage: 'Thông tin hoặc file nộp đồ án không hợp lệ.',
    );
  }

  Future<T> _guard<T>(
    Future<T> Function() action, {
    required String invalidDataMessage,
  }) async {
    try {
      return await action();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          invalidDataMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

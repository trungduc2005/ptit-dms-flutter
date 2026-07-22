import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_post_defense_submission_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_post_defense_submission_repository.dart';

class ProjectPostDefenseSubmissionRepositoryImpl
    implements ProjectPostDefenseSubmissionRepository {
  ProjectPostDefenseSubmissionRepositoryImpl(
    this._remoteDataSource,
    this._mapper,
  );

  final ProjectPostDefenseSubmissionRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<ProjectPostDefenseSubmission> getSubmission({
    required String projectId,
    required String academicYearId,
  }) {
    return _guard(
      () => _remoteDataSource.getSubmission(
        projectId: projectId,
        academicYearId: academicYearId,
      ),
      invalidDataMessage: 'Dữ liệu nộp đồ án sau bảo vệ không hợp lệ.',
    );
  }

  @override
  Future<void> uploadSubmission({
    required ProjectPostDefenseSubmissionRequest request,
    ProjectPostDefenseUploadProgressCallback? onSendProgress,
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

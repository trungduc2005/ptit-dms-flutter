import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_progress_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_progress_report_repository.dart';

class ProjectProgressReportRepositoryImpl
    implements ProjectProgressReportRepository {
  ProjectProgressReportRepositoryImpl(this._remoteDataSource, this._mapper);

  final ProjectProgressReportRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<ProjectProgressReport>> getReports({
    required String projectObjectId,
    required String academicYearId,
  }) {
    return _guard(
      () => _remoteDataSource.getReports(
        projectObjectId: projectObjectId,
        academicYearId: academicYearId,
      ),
      invalidDataMessage: 'Dữ liệu báo cáo tiến độ không hợp lệ.',
    );
  }

  @override
  Future<List<ProjectReportReply>> getReplies({
    required String projectId,
    required String academicYearId,
  }) {
    return _guard(
      () => _remoteDataSource.getReplies(
        projectId: projectId,
        academicYearId: academicYearId,
      ),
      invalidDataMessage: 'Dữ liệu phản hồi báo cáo không hợp lệ.',
    );
  }

  @override
  Future<ProjectProgressReport> createReport({
    required ProjectProgressReportRequest request,
  }) {
    return _guard(
      () => _remoteDataSource.createReport(request: request),
      invalidDataMessage: 'Dữ liệu tạo báo cáo tiến độ không hợp lệ.',
    );
  }

  @override
  Future<ProjectProgressReport> updateReport({
    required ProjectProgressReportRequest request,
  }) {
    return _guard(
      () => _remoteDataSource.updateReport(request: request),
      invalidDataMessage: 'Dữ liệu cập nhật báo cáo tiến độ không hợp lệ.',
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

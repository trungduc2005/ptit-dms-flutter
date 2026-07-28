import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_result_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_result_repository.dart';

class ProjectResultRepositoryImpl implements ProjectResultRepository {
  ProjectResultRepositoryImpl(this._remoteDataSource, this._mapper);

  final ProjectResultRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<ProjectResult> getProjectResult({
    required String projectId,
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getProjectResult(
        projectId: projectId,
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu kết quả đồ án tốt nghiệp không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

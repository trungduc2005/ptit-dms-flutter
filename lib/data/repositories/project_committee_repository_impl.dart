import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_committee_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_committee_repository.dart';

class ProjectCommitteeRepositoryImpl implements ProjectCommitteeRepository {
  ProjectCommitteeRepositoryImpl(this._remoteDataSource, this._mapper);

  final ProjectCommitteeRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<ProjectCommittee> getMyProjectCommittee({
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getMyProjectCommittee(
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu hội đồng đồ án không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

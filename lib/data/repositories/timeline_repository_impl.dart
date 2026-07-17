import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/timeline_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._remoteDataSource, this._mapper);

  final TimelineRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<Timeline>> getInternTimelines({
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getInternTimelines(
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<List<Timeline>> getProjectTimelines({
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getProjectTimelines(
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}

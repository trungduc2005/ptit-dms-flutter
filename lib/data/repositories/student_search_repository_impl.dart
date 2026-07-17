import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/student_search_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_search_repository.dart';

class StudentSearchRepositoryImpl implements StudentSearchRepository {
  StudentSearchRepositoryImpl(this._remoteDataSource, this._mapper);

  final StudentSearchRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<StudentSearchResult>> searchInternEligibleStudents({
    required String query,
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.searchInternEligibleStudents(
        query: query,
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<List<StudentSearchResult>> searchProjectEligibleStudents({
    required String query,
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.searchProjectEligibleStudents(
        query: query,
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}
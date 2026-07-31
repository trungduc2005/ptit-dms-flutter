import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_member_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';

class ResearchRepositoryImpl implements ResearchRepository {
  ResearchRepositoryImpl(this._remoteDataSource, this._mapper);

  final ResearchRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<Research>> getUserResearches({
    required String yearId,
    required String type,
  }) async {
    try {
      return await _remoteDataSource.getUserResearches(
        yearId: yearId,
        type: type,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu nghiên cứu khoa học không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<List<ResearchMemberOption>> searchLecturers({
    required String query,
  }) async {
    try {
      return await _remoteDataSource.searchLecturers(query: query);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu giảng viên không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<List<ResearchMemberOption>> searchStudents({
    required String query,
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.searchStudents(
        query: query,
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu sinh viên không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<Research> createResearch({
    required ResearchRegistrationRequest request,
  }) async {
    try {
      return await _remoteDataSource.createResearch(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu đăng ký nghiên cứu khoa học không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<Research> updateResearch({
    required String researchId,
    required ResearchRegistrationRequest request,
  }) async {
    try {
      return await _remoteDataSource.updateResearch(
        researchId: researchId,
        request: request,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu cập nhật nghiên cứu khoa học không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

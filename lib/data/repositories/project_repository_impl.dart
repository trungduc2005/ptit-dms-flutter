import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._remoteDataSource, this._mapper);

  final ProjectRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<Project?> checkProject({
    required String academicYearId,
    required String studentId,
  }) async {
    try {
      return await _remoteDataSource.checkProject(
        academicYearId: academicYearId,
        studentId: studentId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu đồ án không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<List<ProjectPeriodOption>> getProjectPeriods() async {
    try {
      return await _remoteDataSource.getProjectPeriods();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu đợt đăng ký đồ án không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<List<ProjectGuiderOption>> getProjectGuiders({
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getProjectGuiders(
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu giảng viên hướng dẫn không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<Project> registerProject({
    required ProjectRegistrationRequest request,
  }) async {
    try {
      return await _remoteDataSource.registerProject(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu đăng ký đồ án không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<Project> updateProject({
    required ProjectRegistrationRequest request,
  }) async {
    try {
      return await _remoteDataSource.updateProject(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu cập nhật đồ án không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> approveProjectMembership({
    required String projectId,
    required String studentRef,
  }) async {
    try {
      return await _remoteDataSource.approveProjectMembership(
        projectId: projectId,
        studentRef: studentRef,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<void> rejectProjectMembership({
    required String projectId,
    required String studentRef,
    String? reason,
  }) async {
    try {
      return await _remoteDataSource.rejectProjectMembership(
        projectId: projectId,
        studentRef: studentRef,
        reason: reason,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}

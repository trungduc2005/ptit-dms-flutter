import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/student_profile_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_check.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_update_request.dart';

class StudentProfileRepositoryImpl implements StudentProfileRepository {
  StudentProfileRepositoryImpl(this._remoteDataSource, this._mapper);

  final StudentProfileRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<StudentProfile> getProfile() async {
    try {
      return await _remoteDataSource.getProfile();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu hồ sơ sinh viên không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<StudentProfile> updateProfile({
    required StudentProfileUpdateRequest request,
  }) async {
    try {
      return await _remoteDataSource.updateProfile(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu cập nhật hồ sơ không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<AvatarUploadResult> uploadAvatar({required String filePath}) async {
    try {
      return await _remoteDataSource.uploadAvatar(filePath: filePath);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Kết quả tải ảnh đại diện không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<RequiredProfileCheck> checkRequiredProfile() async {
    try {
      return await _remoteDataSource.checkRequiredProfile();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu kiểm tra thông tin bắt buộc không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> updateRequiredProfile({
    required RequiredProfileUpdateRequest request,
  }) async {
    try {
      return await _remoteDataSource.updateRequiredProfile(request: request);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu cập nhật thông tin bắt buộc không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}
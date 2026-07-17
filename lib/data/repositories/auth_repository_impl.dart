import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_login_result.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_session.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._cookieJar, this._mapper);

  final AuthRemoteDataSource _remoteDataSource;
  final CookieJar _cookieJar;
  final DioExceptionMapper _mapper;

  @override
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.login(
        username: username,
        password: password,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<AuthSession> checkSession() async {
    try {
      return await _remoteDataSource.verify();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _cookieJar.deleteAll();
    }
  }
}
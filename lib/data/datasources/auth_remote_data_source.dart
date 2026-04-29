import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_login_result.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_session.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
      options: Options(extra: const {'skipAuthRefresh': true}),
    );

    return AuthLoginResult.fromJson(asJsonMap(response.data));
  }

  Future<AuthSession> verify() async {
    final response = await _dio.get('/auth/verify');
    return AuthSession.fromJson(asJsonMap(response.data));
  }

  Future<void> logout() async {
    await _dio.post(
      '/auth/logout',
      options: Options(extra: const {'skipAuthRefresh': true}),
    );
  }
}

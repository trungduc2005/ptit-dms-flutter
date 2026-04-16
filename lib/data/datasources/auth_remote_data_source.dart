import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/data/models/auth_login_response_model.dart';
import 'package:ptit_dms_flutter/data/models/auth_verify_response_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthLoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
      options: Options(extra: const {'skipAuthRefresh': true}),
    );

    return AuthLoginResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<AuthVerifyResponseModel> verify() async {
    final response = await _dio.get('/auth/verify');
    return AuthVerifyResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<void> logout() async {
    await _dio.post(
      '/auth/logout',
      options: Options(extra: const {'skipAuthRefresh': true}),
    );
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}

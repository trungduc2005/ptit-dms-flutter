import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
      options: Options(extra: const {'skipAuthRefresh': true}),
    );

    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> verify() async {
    final response = await _dio.get('/auth/verify');
    return _asMap(response.data);
  }

  Future<void> logout() async {
    await _dio.post(
      '/auth/logout',
      options: Options(extra: const {'skipAuthRefresh': true}),
    );
  }
}

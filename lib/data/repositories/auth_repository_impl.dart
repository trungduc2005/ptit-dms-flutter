import 'package:cookie_jar/cookie_jar.dart';
import 'package:ptit_dms_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl(this._remoteDataSource, this._cookieJar);

  final AuthRemoteDataSource _remoteDataSource;
  final CookieJar _cookieJar;

  @override
  Future<Map<String, dynamic>> login({required String username, required String password}) {
    return _remoteDataSource.login(username: username, password: password);
  }
  
  @override
  Future<Map<String, dynamic>> checkSession() {
    return _remoteDataSource.verify();
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
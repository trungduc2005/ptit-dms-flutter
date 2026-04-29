import 'package:cookie_jar/cookie_jar.dart';
import 'package:ptit_dms_flutter/data/datasources/auth_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_login_result.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_session.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._cookieJar);

  final AuthRemoteDataSource _remoteDataSource;
  final CookieJar _cookieJar;

  @override
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) {
    return _remoteDataSource.login(username: username, password: password);
  }

  @override
  Future<AuthSession> checkSession() {
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

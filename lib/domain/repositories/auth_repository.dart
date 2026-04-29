import 'package:ptit_dms_flutter/domain/entities/auth_login_result.dart';
import 'package:ptit_dms_flutter/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  });

  Future<AuthSession> checkSession();

  Future<void> logout();
}

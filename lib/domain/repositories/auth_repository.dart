import 'package:ptit_dms_flutter/data/models/auth_login_response_model.dart';
import 'package:ptit_dms_flutter/data/models/auth_verify_response_model.dart';

abstract class AuthRepository {
  Future<AuthLoginResponseModel> login({
    required String username,
    required String password,
  });

  Future<AuthVerifyResponseModel> checkSession();

  Future<void> logout();
}

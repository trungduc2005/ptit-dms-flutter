abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> checkSession();

  Future<void> logout();
}

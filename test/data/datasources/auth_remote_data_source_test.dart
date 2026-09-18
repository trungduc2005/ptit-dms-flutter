import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/auth_remote_data_source.dart';

void main() {
  Dio createStubDio(
    Object? responseData, {
    void Function(RequestOptions options)? capture,
  }) {
    return Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capture?.call(options);
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: responseData,
              ),
            );
          },
        ),
      );
  }

  group('AuthRemoteDataSource', () {
    test('login sends credentials and returns AuthLoginResult', () async {
      RequestOptions? captured;
      final dataSource = AuthRemoteDataSource(
        createStubDio(
          {'success': true, 'userId': 'user-01', 'role': 'student'},
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.login(
        username: 'B21DCCN001',
        password: 'secretPassword',
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, '/auth/login');
      expect(captured!.data, {
        'username': 'B21DCCN001',
        'password': 'secretPassword',
      });
      expect(captured!.extra['skipAuthRefresh'], isTrue);
      expect(result.success, isTrue);
      expect(result.userId, 'user-01');
      expect(result.role, 'student');
    });

    test('verify sends bearer auth request and returns AuthSession', () async {
      RequestOptions? captured;
      final dataSource = AuthRemoteDataSource(
        createStubDio(
          {
            'valid': true,
            'user': {
              'userId': 'user-01',
              'username': 'B21DCCN001',
              'role': 'student',
            },
          },
          capture: (options) => captured = options,
        ),
      );

      final session = await dataSource.verify();

      expect(captured!.method, 'GET');
      expect(captured!.path, '/auth/verify');
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(session.valid, isTrue);
      expect(session.user?.username, 'B21DCCN001');
    });

    test('logout sends bearer auth request and skips refresh', () async {
      RequestOptions? captured;
      final dataSource = AuthRemoteDataSource(
        createStubDio(
          {'success': true, 'message': 'Đăng xuất thành công'},
          capture: (options) => captured = options,
        ),
      );

      await dataSource.logout();

      expect(captured!.method, 'POST');
      expect(captured!.path, '/auth/logout');
      expect(captured!.extra['skipAuthRefresh'], isTrue);
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
    });
  });
}

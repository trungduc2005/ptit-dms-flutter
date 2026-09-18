import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';

class _TestRequestInterceptorHandler extends RequestInterceptorHandler {
  RequestOptions? passedOptions;
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
    passedOptions = requestOptions;
  }
}

void main() {
  group('BearerAuthInterceptor', () {
    late CookieJar cookieJar;
    late BearerAuthInterceptor interceptor;

    setUp(() {
      cookieJar = CookieJar();
      interceptor = BearerAuthInterceptor(cookieJar);
    });

    test(
      'attaches Authorization header with Bearer when accessToken cookie exists',
      () async {
        final uri = Uri.parse('https://example.com/api/info');
        await cookieJar.saveFromResponse(uri, [
          Cookie('accessToken', 'my-access-token'),
        ]);

        final options = RequestOptions(
          path: '/info',
          baseUrl: 'https://example.com/api',
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(
          options.headers[authorizationHeaderName],
          'Bearer my-access-token',
        );
      },
    );

    test(
      'falls back to legacy token cookie if accessToken is not present',
      () async {
        final uri = Uri.parse('https://example.com/api/info');
        await cookieJar.saveFromResponse(uri, [
          Cookie('token', 'my-legacy-token'),
        ]);

        final options = RequestOptions(
          path: '/info',
          baseUrl: 'https://example.com/api',
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(
          options.headers[authorizationHeaderName],
          'Bearer my-legacy-token',
        );
      },
    );

    test(
      'prefers accessToken over legacy token if both are present',
      () async {
        final uri = Uri.parse('https://example.com/api/info');
        await cookieJar.saveFromResponse(uri, [
          Cookie('accessToken', 'primary-token'),
          Cookie('token', 'legacy-token'),
        ]);

        final options = RequestOptions(
          path: '/info',
          baseUrl: 'https://example.com/api',
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(
          options.headers[authorizationHeaderName],
          'Bearer primary-token',
        );
      },
    );

    test(
      'does not attach Authorization header if no token cookie exists',
      () async {
        final options = RequestOptions(
          path: '/info',
          baseUrl: 'https://example.com/api',
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(options.headers.containsKey(authorizationHeaderName), isFalse);
      },
    );

    test(
      'does not attach Authorization header for /auth/login endpoint',
      () async {
        final uri = Uri.parse('https://example.com/api/auth/login');
        await cookieJar.saveFromResponse(uri, [
          Cookie('accessToken', 'my-access-token'),
        ]);

        final options = RequestOptions(
          path: '/auth/login',
          baseUrl: 'https://example.com/api',
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(options.headers.containsKey(authorizationHeaderName), isFalse);
      },
    );

    test(
      'does not attach Authorization header when requiresBearerAuth is explicitly false',
      () async {
        final uri = Uri.parse('https://example.com/api/public/data');
        await cookieJar.saveFromResponse(uri, [
          Cookie('accessToken', 'my-access-token'),
        ]);

        final options = RequestOptions(
          path: '/public/data',
          baseUrl: 'https://example.com/api',
          extra: {requiresBearerAuthKey: false},
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(options.headers.containsKey(authorizationHeaderName), isFalse);
      },
    );

    test(
      'attaches Authorization header when requiresBearerAuth is explicitly true',
      () async {
        final uri = Uri.parse('https://example.com/api/info');
        await cookieJar.saveFromResponse(uri, [
          Cookie('accessToken', 'my-access-token'),
        ]);

        final options = RequestOptions(
          path: '/info',
          baseUrl: 'https://example.com/api',
          extra: {requiresBearerAuthKey: true},
        );
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(handler.nextCalled, isTrue);
        expect(
          options.headers[authorizationHeaderName],
          'Bearer my-access-token',
        );
      },
    );
  });
}


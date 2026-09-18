import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

const requiresBearerAuthKey = 'requiresBearerAuth';
const primaryAccessTokenCookieName = 'accessToken';
const legacyAccessTokenCookieName = 'token';
const authorizationHeaderName = 'Authorization';

class BearerAuthInterceptor extends Interceptor {
  BearerAuthInterceptor(this._cookieJar);

  final CookieJar _cookieJar;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If bearer auth is explicitly disabled or it's the login endpoint, proceed without adding token
    if (options.extra[requiresBearerAuthKey] == false ||
        options.path == '/auth/login') {
      handler.next(options);
      return;
    }

    final cookies = await _cookieJar.loadForRequest(options.uri);

    String? accessToken;

    for (final cookie in cookies) {
      if (cookie.name == primaryAccessTokenCookieName) {
        accessToken = cookie.value;
        break;
      }
      if (cookie.name == legacyAccessTokenCookieName) {
        accessToken ??= cookie.value;
      }
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[authorizationHeaderName] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}

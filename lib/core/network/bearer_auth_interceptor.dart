import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

const requiresBearerAuthKey = 'requiresBearerAuth';
const accessTokenCookieName = 'token';
const authorizationHeaderName = 'Authorization';

class BearerAuthInterceptor extends Interceptor {
  BearerAuthInterceptor(this._cookieJar);

  final CookieJar _cookieJar;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[requiresBearerAuthKey] != true) {
      handler.next(options);
      return;
    }

    final cookies = await _cookieJar.loadForRequest(options.uri);

    String? accessToken;

    for (final cookie in cookies) {
      if (cookie.name == accessTokenCookieName) {
        accessToken = cookie.value;
        break;
      }
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[authorizationHeaderName] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}

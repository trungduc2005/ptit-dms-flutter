import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

const csrfCookieName = 'csrfToken';
const csrfHeaderName = 'x-csrf-token';

class CsrfInterceptor extends Interceptor {
  CsrfInterceptor(this._cookieJar);

  final CookieJar _cookieJar;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cookies = await _cookieJar.loadForRequest(options.uri);

    String? csrfToken; 
    for(final cookie in cookies){
      if(cookie.name == csrfCookieName){
        csrfToken = cookie.value;
        break;
      }
    }

    if(csrfToken != null && csrfToken.isNotEmpty){
      options.headers[csrfHeaderName] = csrfToken;
    }

    handler.next(options);
  }
}
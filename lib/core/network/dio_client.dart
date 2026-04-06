import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ptit_dms_flutter/core/network/auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';

import 'csrf_interceptor.dart';

const apiBaseUrl = 'https://beta.ptit.me/api';

Dio createDioClient(CookieJar cookieJar) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(CookieManager(cookieJar));
  dio.interceptors.add(CsrfInterceptor(cookieJar));
  dio.interceptors.add(BearerAuthInterceptor(cookieJar));
  dio.interceptors.add(AuthInterceptor(dio));

  return dio;
}

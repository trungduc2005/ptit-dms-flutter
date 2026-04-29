import 'package:dio/dio.dart';

const _skipAuthRefreshKey = 'skipAuthRefresh';
const _retriedKey = 'retried';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;
  Future<void>? _refreshFuture;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(err)) {
      handler.next(err);
      return;
    }
    try {
      await _refreshToken();
      final response = await _retry(err.requestOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldRefresh(DioException err) {
    final requestOptions = err.requestOptions;
    final statusCode = err.response?.statusCode;
    final errorCode = _extractErrorCode(err.response?.data);

    return statusCode == 401 &&
        requestOptions.extra[_skipAuthRefreshKey] != true &&
        requestOptions.extra[_retriedKey] != true &&
        requestOptions.path != '/auth/refresh' &&
        (errorCode == 'ACCESS_TOKEN_EXPIRED' ||
            errorCode == 'ACCESS_TOKEN_MISSING');
  }

  String? _extractErrorCode(Object? data) {
    if (data is Map) {
      final code = data['code'] ?? data['errorCode'] ?? data['error'];
      return code?.toString();
    }
    return null;
  }

  Future<void> _refreshToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    _refreshFuture = _dio
        .post(
          '/auth/refresh',
          options: Options(extra: const {_skipAuthRefreshKey: true}),
        )
        .then((_) {});

    try {
      await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final extra = Map<String, dynamic>.from(requestOptions.extra);
    extra[_retriedKey] = true;

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: extra,
        responseType: requestOptions.responseType,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        listFormat: requestOptions.listFormat,
      ),
    );
  }
}

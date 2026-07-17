import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';

/// Maps [DioException] to a typed [AppException].
///
/// This class belongs to the data layer and must NOT be imported by
/// presentation (BLoC, page, widget).
class DioExceptionMapper {
  const DioExceptionMapper();

  /// Maps [error] to the corresponding [AppException].
  ///
  /// Never throws; always returns a concrete [AppException] subclass.
  AppException map(DioException error, StackTrace stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Kết nối bị timeout. Vui lòng kiểm tra mạng và thử lại.',
          cause: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
          cause: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          'Yêu cầu đã bị hủy.',
          cause: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        return _mapBadResponse(error, stackTrace);

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Chứng chỉ SSL không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        );

      case DioExceptionType.unknown:
        return UnexpectedException(
          'Đã xảy ra lỗi không xác định.',
          cause: error,
          stackTrace: stackTrace,
        );
    }
  }

  AppException _mapBadResponse(DioException error, StackTrace stackTrace) {
    final statusCode = error.response?.statusCode;
    final message = _extractMessage(error);

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException(
        message ?? 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (statusCode == 400 || statusCode == 422) {
      return ValidationException(
        message ?? 'Dữ liệu không hợp lệ.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message ?? 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
        statusCode: statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return UnexpectedException(
      message ?? 'Đã xảy ra lỗi không xác định (HTTP $statusCode).',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  /// Safely extracts a backend error message.
  ///
  /// Returns null if the response body is not a Map or lacks a message field.
  String? _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg != null) return msg.toString();
    }
    return error.message;
  }
}
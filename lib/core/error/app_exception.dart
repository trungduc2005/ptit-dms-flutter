/// Application-level exception hierarchy.
///
/// These exceptions are thrown by repository implementations and caught by
/// BLoCs/presentation layer. The presentation layer must NOT import
/// package:dio/dio.dart — it only knows about [AppException] subclasses.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// A network-level error such as timeout, no connection, or cancelled request.
final class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// The server returned 401 or 403 (authentication / authorisation failure).
final class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}

/// The server returned a 4xx validation / bad-request error.
final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  });

  final Map<String, String> fieldErrors;
}

/// The server returned a 5xx error.
final class ServerException extends AppException {
  const ServerException(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
}

/// An error that was not anticipated: parse failures, type mismatches, etc.
final class UnexpectedException extends AppException {
  const UnexpectedException(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';

DioException _makeDio({
  required DioExceptionType type,
  int? statusCode,
  dynamic data,
  String? message,
}) {
  final response =
      statusCode != null
          ? Response(
            requestOptions: RequestOptions(),
            statusCode: statusCode,
            data: data,
          )
          : null;
  return DioException(
    requestOptions: RequestOptions(),
    type: type,
    response: response,
    message: message,
  );
}

void main() {
  const mapper = DioExceptionMapper();

  group('DioExceptionMapper.map –', () {
    test('connectionTimeout → NetworkException', () {
      final ex = _makeDio(type: DioExceptionType.connectionTimeout);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<NetworkException>());
    });

    test('sendTimeout → NetworkException', () {
      final ex = _makeDio(type: DioExceptionType.sendTimeout);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<NetworkException>());
    });

    test('receiveTimeout → NetworkException', () {
      final ex = _makeDio(type: DioExceptionType.receiveTimeout);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<NetworkException>());
    });

    test('connectionError → NetworkException', () {
      final ex = _makeDio(type: DioExceptionType.connectionError);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<NetworkException>());
    });

    test('cancel → NetworkException', () {
      final ex = _makeDio(type: DioExceptionType.cancel);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<NetworkException>());
    });

    test('badCertificate → NetworkException', () {
      final ex = _makeDio(type: DioExceptionType.badCertificate);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<NetworkException>());
    });

    test('unknown → UnexpectedException', () {
      final ex = _makeDio(type: DioExceptionType.unknown);
      final result = mapper.map(ex, StackTrace.current);
      expect(result, isA<UnexpectedException>());
    });

    group('badResponse –', () {
      test('401 → UnauthorizedException', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 401,
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result, isA<UnauthorizedException>());
      });

      test('403 → UnauthorizedException', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 403,
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result, isA<UnauthorizedException>());
      });

      test('400 → ValidationException', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 400,
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result, isA<ValidationException>());
      });

      test('422 → ValidationException', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 422,
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result, isA<ValidationException>());
      });

      test('500 → ServerException with statusCode', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 500,
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result, isA<ServerException>());
        expect((result as ServerException).statusCode, 500);
      });

      test('503 → ServerException', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 503,
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result, isA<ServerException>());
      });

      test('extracts message from response body map', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'message': 'Trường bắt buộc không được để trống'},
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result.message, 'Trường bắt buộc không được để trống');
      });

      test('falls back to default message when body has no message key', () {
        final ex = _makeDio(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: {'error': 'bad request'},
        );
        final result = mapper.map(ex, StackTrace.current);
        expect(result.message, isNotEmpty);
      });
    });
  });
}
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';

void main() {
  test('reads message from dio response data', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Server message'},
      ),
    );

    expect(readDioErrorMessage(error), 'Server message');
  });

  test('falls back to dio message then provided fallback', () {
    final withMessage = DioException(
      requestOptions: RequestOptions(path: '/test'),
      message: 'Dio message',
    );
    final withoutMessage = DioException(
      requestOptions: RequestOptions(path: '/test'),
    );

    expect(
      readDioErrorMessage(withMessage, fallback: 'Fallback'),
      'Dio message',
    );
    expect(
      readDioErrorMessage(withoutMessage, fallback: 'Fallback'),
      'Fallback',
    );
  });
}

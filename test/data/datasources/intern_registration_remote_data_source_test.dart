import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_registration_remote_data_source.dart';

void main() {
  test(
    'getCurrentRegistration supports backend data.intern response shape',
    () async {
      final adapter = _RecordingAdapter({
        'success': true,
        'data': {
          'intern': {
            '_id': 'reg-1',
            'studentId': 'B21DCCN001',
            'type': 'registerWish',
            'preferredCompanies': const [],
            'rejectReasons': const [],
            'cvFileName': 'cv.pdf',
            'cvFileKey': 'cv-key',
          },
          'expectedStartTime': '2026-06-01T00:00:00.000Z',
          'expectedEndTime': '2026-08-01T00:00:00.000Z',
        },
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final dataSource = InternRegistrationRemoteDataSource(dio);

      final registration = await dataSource.getCurrentRegistration(
        academicYearId: 'ay-1',
      );

      expect(adapter.lastOptions?.path, '/interns/registrations');
      expect(adapter.lastOptions?.queryParameters, {'academicYearId': 'ay-1'});
      expect(registration?.id, 'reg-1');
      expect(registration?.cvFileName, 'cv.pdf');
      expect(
        registration?.expectedStartTime,
        DateTime.parse('2026-06-01T00:00:00.000Z'),
      );
      expect(
        registration?.expectedEndTime,
        DateTime.parse('2026-08-01T00:00:00.000Z'),
      );
    },
  );

  test(
    'getCurrentRegistration returns null when backend data.intern is null',
    () async {
      final adapter = _RecordingAdapter({
        'success': true,
        'data': {
          'intern': null,
          'expectedStartTime': '2026-06-01T00:00:00.000Z',
          'expectedEndTime': '2026-08-01T00:00:00.000Z',
        },
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final dataSource = InternRegistrationRemoteDataSource(dio);

      final registration = await dataSource.getCurrentRegistration(
        academicYearId: 'ay-1',
      );

      expect(registration, isNull);
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.responseData);

  final Object responseData;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;

    return ResponseBody.fromString(
      jsonEncode(responseData),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/intern_cv_remote_data_source.dart';

void main() {
  test(
    'uploadAcceptedCompanyEvidence posts evidenceFile multipart field',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'intern-evidence-test',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final file = File('${tempDir.path}/evidence.pdf');
      await file.writeAsBytes([1, 2, 3]);

      final adapter = _RecordingAdapter({
        'success': true,
        'data': {
          'evidenceFileName': 'B21DCCN001-Nguyen-Van-A-Evid.pdf',
          'evidenceFileKey': 'internships/2026/B21DCCN001/evidence/file',
          'evidenceFileType': 'pdf',
        },
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final dataSource = InternCvRemoteDataSource(dio);

      final result = await dataSource.uploadAcceptedCompanyEvidence(
        academicYearId: 'ay-1',
        filePath: file.path,
      );

      expect(
        adapter.lastOptions?.path,
        '/interns/registrations/accepted-company-proof/evidence',
      );
      expect(adapter.lastOptions?.queryParameters, {'academicYearId': 'ay-1'});
      expect(
        adapter.lastOptions?.contentType,
        startsWith(Headers.multipartFormDataContentType),
      );
      expect(adapter.lastOptions?.data, isA<FormData>());

      final formData = adapter.lastOptions!.data as FormData;
      expect(formData.files.single.key, 'evidenceFile');
      expect(formData.files.single.value.filename, 'evidence.pdf');
      expect(
        result.evidenceFileKey,
        'internships/2026/B21DCCN001/evidence/file',
      );
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
    await requestStream?.drain<void>();

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

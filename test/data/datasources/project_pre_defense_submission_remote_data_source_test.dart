import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_pre_defense_submission_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';

void main() {
  Dio createStubDio(
    Object? Function(RequestOptions options) responseData, {
    void Function(RequestOptions options)? capture,
  }) {
    return Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capture?.call(options);
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: responseData(options),
              ),
            );
          },
        ),
      );
  }

  Map<String, dynamic> submittedResponse() {
    return {
      'success': true,
      'status': 'rejected',
      'submissions': [
        {
          'files': [
            {
              'fileName': 'B20DCCN001-Thesis-20260721',
              'fileKey': 'projects/year/project/pre-report/thesis.pdf',
              'fileType': 'pdf',
            },
            {
              'fileName': 'B20DCCN001-Turnitin-Report-20260721',
              'fileKey': 'projects/year/project/pre-report/turnitin.docx',
              'fileType': 'docx',
            },
          ],
          'approval': {
            'guider': {
              'status': 'rejected',
              'approverRef': {'_id': 'lecturer-01'},
              'comment': 'Cần sửa định dạng',
              'approvedAt': '2026-07-21T05:00:00.000Z',
            },
          },
          'uploadedAt': '2026-07-21T04:00:00.000Z',
        },
      ],
    };
  }

  group('ProjectPreDefenseSubmissionRemoteDataSource', () {
    test('gets and parses submission history', () async {
      RequestOptions? captured;
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio(
          (_) => submittedResponse(),
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.getSubmission(
        projectId: 'PROJECT-01',
        academicYearId: 'year-01',
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, '/projects/pre-report-files/PROJECT-01');
      expect(captured!.queryParameters, {'academicYearId': 'year-01'});
      expect(result.status, ProjectPreDefenseSubmissionStatus.rejected);
      expect(result.hasSubmitted, isTrue);
      expect(result.canResubmit, isTrue);
      expect(result.latestSubmission!.files, hasLength(2));
      expect(
        result.latestSubmission!.guiderApproval.comment,
        'Cần sửa định dạng',
      );
      expect(
        result.latestSubmission!.guiderApproval.approverRef,
        'lecturer-01',
      );
    });

    test('parses backend empty files response as not submitted', () async {
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': true, 'files': <Object?>[]}),
      );

      final result = await dataSource.getSubmission(
        projectId: 'PROJECT-01',
        academicYearId: 'year-01',
      );

      expect(result.hasSubmitted, isFalse);
      expect(result.status, isNull);
      expect(result.latestSubmission, isNull);
      expect(result.canResubmit, isTrue);
    });

    test('uploads byte files with exact backend multipart fields', () async {
      RequestOptions? captured;
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio(
          (_) => {'success': true, 'message': 'Thành công'},
          capture: (options) => captured = options,
        ),
      );
      final request = ProjectPreDefenseSubmissionRequest(
        projectId: ' PROJECT-01 ',
        academicYearId: ' year-01 ',
        thesisFile: ProjectPreDefenseUploadFile(
          fileName: 'thesis.pdf',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        turnitinReportFile: ProjectPreDefenseUploadFile(
          fileName: 'turnitin.docx',
          bytes: Uint8List.fromList([4, 5]),
        ),
      );

      await dataSource.uploadSubmission(request: request);

      expect(captured!.method, 'POST');
      expect(captured!.path, '/projects/pre-report-files/upload');
      expect(
        captured!.contentType,
        startsWith(Headers.multipartFormDataContentType),
      );

      final formData = captured!.data as FormData;
      expect(Map<String, String>.fromEntries(formData.fields), {
        'projectId': 'PROJECT-01',
        'academicYearId': 'year-01',
      });
      expect(
        formData.files.map((entry) => entry.key),
        containsAllInOrder(['thesisFile', 'turnitinReportFile']),
      );
      expect(formData.files[0].value.filename, 'thesis.pdf');
      expect(formData.files[1].value.filename, 'turnitin.docx');
    });

    test('rejects request without any file before sending', () async {
      var requestWasSent = false;
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio(
          (_) => {'success': true},
          capture: (_) => requestWasSent = true,
        ),
      );

      await expectLater(
        dataSource.uploadSubmission(
          request: const ProjectPreDefenseSubmissionRequest(
            projectId: 'PROJECT-01',
            academicYearId: 'year-01',
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(requestWasSent, isFalse);
    });

    test('rejects unsupported file extension before sending', () async {
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': true}),
      );

      await expectLater(
        dataSource.uploadSubmission(
          request: ProjectPreDefenseSubmissionRequest(
            projectId: 'PROJECT-01',
            academicYearId: 'year-01',
            thesisFile: ProjectPreDefenseUploadFile(
              fileName: 'thesis.zip',
              bytes: Uint8List.fromList([1]),
            ),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects file larger than backend 25 MB limit', () async {
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': true}),
      );

      await expectLater(
        dataSource.uploadSubmission(
          request: ProjectPreDefenseSubmissionRequest(
            projectId: 'PROJECT-01',
            academicYearId: 'year-01',
            thesisFile: ProjectPreDefenseUploadFile(
              fileName: 'thesis.pdf',
              bytes: Uint8List.fromList([1]),
              size: ProjectPreDefenseSubmissionRequest.maxFileSizeInBytes + 1,
            ),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when upload success flag is false', () async {
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': false}),
      );

      await expectLater(
        dataSource.uploadSubmission(
          request: ProjectPreDefenseSubmissionRequest(
            projectId: 'PROJECT-01',
            academicYearId: 'year-01',
            thesisFile: ProjectPreDefenseUploadFile(
              fileName: 'thesis.pdf',
              bytes: Uint8List.fromList([1]),
            ),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for malformed get response', () async {
      final dataSource = ProjectPreDefenseSubmissionRemoteDataSource(
        createStubDio((_) => <Object?>[]),
      );

      await expectLater(
        dataSource.getSubmission(
          projectId: 'PROJECT-01',
          academicYearId: 'year-01',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

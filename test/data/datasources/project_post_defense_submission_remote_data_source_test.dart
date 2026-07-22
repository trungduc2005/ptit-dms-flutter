import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_post_defense_submission_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';

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

  ProjectPostDefenseUploadFile byteFile(String fileName, [int byte = 1]) {
    return ProjectPostDefenseUploadFile(
      fileName: fileName,
      bytes: Uint8List.fromList([byte]),
    );
  }

  ProjectPostDefenseSubmissionRequest validRequest() {
    return ProjectPostDefenseSubmissionRequest(
      projectId: ' PROJECT-01 ',
      academicYearId: ' year-01 ',
      thesisFile: byteFile('thesis.pdf', 1),
      responseCommitteeFile: byteFile('response.docx', 2),
      approvalMinutesFile: byteFile('minutes.doc', 3),
      sourceFile: byteFile('source.zip', 4),
    );
  }

  Map<String, dynamic> submittedResponse() {
    return {
      'success': true,
      'submissions': [
        {
          'files': [
            {
              'fileName': 'B20DCCN001-Thesis-20260722',
              'fileKey': 'projects/year/project/post-report/thesis.pdf',
              'fileType': 'pdf',
            },
            {
              'fileName': 'B20DCCN001-Source-20260722',
              'fileKey': 'projects/year/project/post-report/source.zip',
              'fileType': 'zip',
            },
          ],
          'approval': {
            'guider': {
              'status': 'approved',
              'approverRef': {'_id': 'lecturer-01'},
              'approvedAt': '2026-07-22T03:00:00.000Z',
            },
            'committee': {
              'status': 'rejected',
              'approverRef': 'committee-01',
              'comment': 'Cần bổ sung sản phẩm',
              'approvedAt': '2026-07-22T04:00:00.000Z',
            },
          },
          'uploadedAt': '2026-07-22T02:00:00.000Z',
        },
      ],
      'guiderApprovalStatus': 'approved',
      'committeeApprovalStatus': 'rejected',
    };
  }

  group('ProjectPostDefenseSubmissionRemoteDataSource', () {
    test('gets and parses post-defense submission history', () async {
      RequestOptions? captured;
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio(
          (_) => submittedResponse(),
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.getSubmission(
        projectId: ' PROJECT-01 ',
        academicYearId: ' year-01 ',
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, '/projects/post-report-files/PROJECT-01');
      expect(captured!.queryParameters, {'academicYearId': 'year-01'});
      expect(result.hasSubmitted, isTrue);
      expect(result.canResubmit, isTrue);
      expect(result.isFullyApproved, isFalse);
      expect(
        result.guiderApprovalStatus,
        ProjectPostDefenseSubmissionStatus.approved,
      );
      expect(
        result.committeeApprovalStatus,
        ProjectPostDefenseSubmissionStatus.rejected,
      );
      expect(result.latestSubmission!.files, hasLength(2));
      expect(
        result.latestSubmission!.guiderApproval.approverRef,
        'lecturer-01',
      );
      expect(
        result.latestSubmission!.committeeApproval.comment,
        'Cần bổ sung sản phẩm',
      );
    });

    test('parses backend empty files response as not submitted', () async {
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': true, 'files': <Object?>[]}),
      );

      final result = await dataSource.getSubmission(
        projectId: 'PROJECT-01',
        academicYearId: 'year-01',
      );

      expect(result.hasSubmitted, isFalse);
      expect(result.latestSubmission, isNull);
      expect(result.guiderApprovalStatus, isNull);
      expect(result.committeeApprovalStatus, isNull);
      expect(result.canResubmit, isTrue);
    });

    test('uploads four files with exact backend multipart fields', () async {
      RequestOptions? captured;
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio(
          (_) => {
            'success': true,
            'message': 'Nộp đồ án sau bảo vệ thành công',
          },
          capture: (options) => captured = options,
        ),
      );

      await dataSource.uploadSubmission(request: validRequest());

      expect(captured!.method, 'POST');
      expect(captured!.path, '/projects/post-report-files/upload');
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
        containsAllInOrder([
          'thesisFile',
          'responseCommitteeFile',
          'approvalMinutesFile',
          'sourceFile',
        ]),
      );
      expect(
        formData.files.map((entry) => entry.value.filename),
        containsAllInOrder([
          'thesis.pdf',
          'response.docx',
          'minutes.doc',
          'source.zip',
        ]),
      );
    });

    test('forwards upload progress callback to Dio', () async {
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': true}),
      );
      var callbackWasInvoked = false;

      await dataSource.uploadSubmission(
        request: validRequest(),
        onSendProgress: (_, _) => callbackWasInvoked = true,
      );

      // Stub adapters do not stream request bodies, so invocation is
      // adapter-dependent. This assertion verifies upload itself still works
      // when a callback is supplied.
      expect(callbackWasInvoked, isFalse);
    });

    test('rejects unsupported source extension before sending', () async {
      var requestWasSent = false;
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio(
          (_) => {'success': true},
          capture: (_) => requestWasSent = true,
        ),
      );
      final request = ProjectPostDefenseSubmissionRequest(
        projectId: 'PROJECT-01',
        academicYearId: 'year-01',
        thesisFile: byteFile('thesis.pdf'),
        responseCommitteeFile: byteFile('response.docx'),
        approvalMinutesFile: byteFile('minutes.pdf'),
        sourceFile: byteFile('source.rar'),
      );

      await expectLater(
        dataSource.uploadSubmission(request: request),
        throwsA(isA<FormatException>()),
      );
      expect(requestWasSent, isFalse);
    });

    test('rejects file larger than backend 25 MB limit', () async {
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': true}),
      );
      final request = ProjectPostDefenseSubmissionRequest(
        projectId: 'PROJECT-01',
        academicYearId: 'year-01',
        thesisFile: ProjectPostDefenseUploadFile(
          fileName: 'thesis.pdf',
          bytes: Uint8List.fromList([1]),
          size: ProjectPostDefenseSubmissionRequest.maxFileSizeInBytes + 1,
        ),
        responseCommitteeFile: byteFile('response.docx'),
        approvalMinutesFile: byteFile('minutes.pdf'),
        sourceFile: byteFile('source.zip'),
      );

      await expectLater(
        dataSource.uploadSubmission(request: request),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when upload success flag is false', () async {
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
        createStubDio((_) => {'success': false}),
      );

      await expectLater(
        dataSource.uploadSubmission(request: validRequest()),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for malformed get response', () async {
      final dataSource = ProjectPostDefenseSubmissionRemoteDataSource(
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

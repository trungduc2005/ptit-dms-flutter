import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/research_pre_acceptance_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';

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

  ResearchPreAcceptanceReportRequest validRequest() {
    return ResearchPreAcceptanceReportRequest(
      researchId: ' RESEARCH-01 ',
      yearId: ' YEAR-01 ',
      reportFile: ResearchPreAcceptanceUploadFile(
        fileName: 'report.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      turnitinReportFile: ResearchPreAcceptanceUploadFile(
        fileName: 'turnitin.docx',
        bytes: Uint8List.fromList([4, 5]),
      ),
    );
  }

  group('ResearchPreAcceptanceReportRemoteDataSource', () {
    test('gets and parses report submission history', () async {
      RequestOptions? captured;
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {
            'success': true,
            'submissions': [
              {
                'numOrder': 1,
                'researchId': 'RESEARCH-01',
                'researchTopic': 'Ứng dụng trí tuệ nhân tạo',
                'reportFile': {
                  'fileName': 'report.pdf',
                  'fileKey': 'researches/year/research/report.pdf',
                  'fileType': 'pdf',
                  'fileUrl': 'https://example.test/report.pdf',
                },
                'turnitinReportFile': {
                  'fileName': 'turnitin.docx',
                  'fileKey': 'researches/year/research/turnitin.docx',
                  'fileType': 'docx',
                  'fileUrl': null,
                },
                'submissionDate': '2026-08-03T05:00:00.000Z',
                'submissionStatus': 'rejected',
                'comment': 'Cần bổ sung nội dung',
                'reviewerId': 'LECTURER-01',
                'reviewerName': 'Nguyễn Văn A',
                'reviewedAt': '2026-08-03T06:00:00.000Z',
              },
            ],
          },
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.getReports(
        researchId: ' RESEARCH/01 ',
        yearId: ' YEAR-01 ',
      );

      expect(captured!.method, 'GET');
      expect(
        captured!.path,
        '/researches/pre-acceptance-reports/RESEARCH%2F01',
      );
      expect(captured!.queryParameters, {'yearId': 'YEAR-01'});
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(result, hasLength(1));

      final report = result.single;
      expect(report.order, 1);
      expect(report.researchId, 'RESEARCH-01');
      expect(report.researchTopic, 'Ứng dụng trí tuệ nhân tạo');
      expect(report.reportFile.fileName, 'report.pdf');
      expect(report.reportFile.fileUrl, 'https://example.test/report.pdf');
      expect(report.turnitinReportFile.fileUrl, isNull);
      expect(report.status, ResearchPreAcceptanceReportStatus.rejected);
      expect(report.comment, 'Cần bổ sung nội dung');
      expect(report.reviewerId, 'LECTURER-01');
      expect(report.reviewerName, 'Nguyễn Văn A');
      expect(report.reviewedAt, DateTime.parse('2026-08-03T06:00:00.000Z'));
    });

    test('parses an empty submission history', () async {
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio((_) => {'success': true, 'submissions': <Object?>[]}),
      );

      final result = await dataSource.getReports(
        researchId: 'RESEARCH-01',
        yearId: 'YEAR-01',
      );

      expect(result, isEmpty);
    });

    test('uploads byte files with exact backend multipart fields', () async {
      RequestOptions? captured;
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {'success': true, 'message': 'Thành công'},
          capture: (options) => captured = options,
        ),
      );

      await dataSource.uploadReport(request: validRequest());

      expect(captured!.method, 'POST');
      expect(captured!.path, '/researches/pre-acceptance-reports/upload');
      expect(
        captured!.contentType,
        startsWith(Headers.multipartFormDataContentType),
      );
      expect(captured!.extra[requiresBearerAuthKey], isTrue);

      final formData = captured!.data as FormData;
      expect(Map<String, String>.fromEntries(formData.fields), {
        'researchId': 'RESEARCH-01',
        'yearId': 'YEAR-01',
      });
      expect(
        formData.files.map((entry) => entry.key),
        containsAllInOrder(['reportFile', 'turnitinReportFile']),
      );
      expect(formData.files[0].value.filename, 'report.pdf');
      expect(formData.files[1].value.filename, 'turnitin.docx');
    });

    test('rejects an unsupported extension before sending', () async {
      var requestWasSent = false;
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {'success': true},
          capture: (_) => requestWasSent = true,
        ),
      );

      await expectLater(
        dataSource.uploadReport(
          request: ResearchPreAcceptanceReportRequest(
            researchId: 'RESEARCH-01',
            yearId: 'YEAR-01',
            reportFile: ResearchPreAcceptanceUploadFile(
              fileName: 'report.zip',
              bytes: Uint8List.fromList([1]),
            ),
            turnitinReportFile: ResearchPreAcceptanceUploadFile(
              fileName: 'turnitin.pdf',
              bytes: Uint8List.fromList([2]),
            ),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(requestWasSent, isFalse);
    });

    test('rejects a file larger than backend 10 MB limit', () async {
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio((_) => {'success': true}),
      );

      await expectLater(
        dataSource.uploadReport(
          request: ResearchPreAcceptanceReportRequest(
            researchId: 'RESEARCH-01',
            yearId: 'YEAR-01',
            reportFile: ResearchPreAcceptanceUploadFile(
              fileName: 'report.pdf',
              bytes: Uint8List.fromList([1]),
              size: ResearchPreAcceptanceReportRequest.maxFileSizeInBytes + 1,
            ),
            turnitinReportFile: ResearchPreAcceptanceUploadFile(
              fileName: 'turnitin.pdf',
              bytes: Uint8List.fromList([2]),
            ),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when success flag is false', () async {
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio((_) => {'success': false}),
      );

      await expectLater(
        dataSource.uploadReport(request: validRequest()),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for a malformed get response', () async {
      final dataSource = ResearchPreAcceptanceReportRemoteDataSource(
        createStubDio((_) => <Object?>[]),
      );

      await expectLater(
        dataSource.getReports(researchId: 'RESEARCH-01', yearId: 'YEAR-01'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

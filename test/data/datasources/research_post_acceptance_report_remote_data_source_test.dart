import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/research_post_acceptance_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';

void main() {
  Dio createStubDio(
    Object? Function(RequestOptions options) responseData, {
    void Function(RequestOptions options)? capture,
    Headers Function(RequestOptions options)? responseHeaders,
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
                headers: responseHeaders?.call(options),
              ),
            );
          },
        ),
      );
  }

  ResearchPostAcceptanceUploadFile uploadFile(
    String fileName, [
    List<int> bytes = const [1],
  ]) {
    return ResearchPostAcceptanceUploadFile(
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
    );
  }

  ResearchPostAcceptanceReportRequest validRequest({
    ResearchPostAcceptanceSubmitterType submitterType =
        ResearchPostAcceptanceSubmitterType.student,
    ResearchPostAcceptanceUploadFile? paperFile,
  }) {
    return ResearchPostAcceptanceReportRequest(
      researchId: ' RESEARCH-01 ',
      yearId: ' YEAR-01 ',
      submitterType: submitterType,
      reportFile: uploadFile('report.pdf', [1, 2]),
      acceptanceMinutesFile: uploadFile('acceptance-minutes.docx', [3]),
      acceptanceCommitteeListFile: uploadFile('committee-list.pdf', [4]),
      proposalFile: uploadFile('proposal.doc', [5]),
      revisionExplanationFile: uploadFile('revision.pdf', [6]),
      acceptanceDecisionFile: uploadFile('decision.pdf', [7]),
      paperFile: paperFile,
    );
  }

  Map<String, Object?> reportFile(String name) {
    return {
      'fileName': name,
      'fileKey': 'researches/year/research/$name',
      'fileType': name.split('.').last,
      'fileUrl': 'https://example.test/$name',
    };
  }

  group('ResearchPostAcceptanceReportRemoteDataSource', () {
    test('gets and parses post-acceptance submission history', () async {
      RequestOptions? captured;
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {
            'success': true,
            'submissions': [
              {
                'numOrder': 1,
                'researchId': 'RESEARCH-01',
                'researchTopic': 'Ứng dụng trí tuệ nhân tạo',
                'reportFile': reportFile('report.pdf'),
                'acceptanceMinutesFile': reportFile('minutes.pdf'),
                'acceptanceCommitteeListFile': reportFile('committee.pdf'),
                'proposalFile': reportFile('proposal.docx'),
                'revisionExplanationFile': reportFile('revision.pdf'),
                'acceptanceDecisionFile': reportFile('decision.pdf'),
                'paperFile': null,
                'submissionDate': '2026-08-03T05:00:00.000Z',
                'submissionStatus': 'submitted',
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
        '/researches/post-acceptance-reports/RESEARCH%2F01',
      );
      expect(captured!.queryParameters, {'yearId': 'YEAR-01'});
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(result, hasLength(1));

      final report = result.single;
      expect(report.order, 1);
      expect(report.researchId, 'RESEARCH-01');
      expect(report.researchTopic, 'Ứng dụng trí tuệ nhân tạo');
      expect(report.reportFile.fileName, 'report.pdf');
      expect(report.acceptanceMinutesFile.fileName, 'minutes.pdf');
      expect(report.acceptanceCommitteeListFile.fileName, 'committee.pdf');
      expect(report.proposalFile.fileName, 'proposal.docx');
      expect(report.revisionExplanationFile.fileName, 'revision.pdf');
      expect(report.acceptanceDecisionFile.fileName, 'decision.pdf');
      expect(report.paperFile, isNull);
      expect(report.submissionDate, DateTime.parse('2026-08-03T05:00:00.000Z'));
      expect(report.status, ResearchPostAcceptanceReportStatus.submitted);
    });

    test('parses optional paper file when present', () async {
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {
            'success': true,
            'submissions': [
              {
                'numOrder': 1,
                'researchId': 'RESEARCH-01',
                'researchTopic': 'Đề tài',
                'reportFile': reportFile('report.pdf'),
                'acceptanceMinutesFile': reportFile('minutes.pdf'),
                'acceptanceCommitteeListFile': reportFile('committee.pdf'),
                'proposalFile': reportFile('proposal.pdf'),
                'revisionExplanationFile': reportFile('revision.pdf'),
                'acceptanceDecisionFile': reportFile('decision.pdf'),
                'paperFile': reportFile('paper.pdf'),
                'submissionDate': '2026-08-03T05:00:00.000Z',
                'submissionStatus': 'submitted',
              },
            ],
          },
        ),
      );

      final result = await dataSource.getReports(
        researchId: 'RESEARCH-01',
        yearId: 'YEAR-01',
      );

      expect(result.single.paperFile?.fileName, 'paper.pdf');
    });

    test('uploads required byte files with exact multipart fields', () async {
      RequestOptions? captured;
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {'success': true, 'message': 'Thành công'},
          capture: (options) => captured = options,
        ),
      );

      await dataSource.uploadReport(request: validRequest());

      expect(captured!.method, 'POST');
      expect(captured!.path, '/researches/post-acceptance-reports/upload');
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
        containsAllInOrder([
          'reportFile',
          'acceptanceMinutesFile',
          'acceptanceCommitteeListFile',
          'proposalFile',
          'revisionExplanationFile',
          'acceptanceDecisionFile',
        ]),
      );
      expect(formData.files.map((entry) => entry.value.filename), [
        'report.pdf',
        'acceptance-minutes.docx',
        'committee-list.pdf',
        'proposal.doc',
        'revision.pdf',
        'decision.pdf',
      ]);
    });

    test('uploads lecturer paper using optional backend field', () async {
      RequestOptions? captured;
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {'success': true},
          capture: (options) => captured = options,
        ),
      );

      await dataSource.uploadReport(
        request: validRequest(
          submitterType: ResearchPostAcceptanceSubmitterType.lecturer,
          paperFile: uploadFile('paper.pdf'),
        ),
      );

      final formData = captured!.data as FormData;
      expect(formData.files.last.key, 'paperFile');
      expect(formData.files.last.value.filename, 'paper.pdf');
    });

    test('rejects lecturer request without paper before sending', () async {
      var requestWasSent = false;
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {'success': true},
          capture: (_) => requestWasSent = true,
        ),
      );

      await expectLater(
        dataSource.uploadReport(
          request: validRequest(
            submitterType: ResearchPostAcceptanceSubmitterType.lecturer,
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(requestWasSent, isFalse);
    });

    test('rejects unsupported extension before sending', () async {
      var requestWasSent = false;
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => {'success': true},
          capture: (_) => requestWasSent = true,
        ),
      );

      final request = validRequest();
      await expectLater(
        dataSource.uploadReport(
          request: ResearchPostAcceptanceReportRequest(
            researchId: request.researchId,
            yearId: request.yearId,
            submitterType: request.submitterType,
            reportFile: uploadFile('report.zip'),
            acceptanceMinutesFile: request.acceptanceMinutesFile,
            acceptanceCommitteeListFile: request.acceptanceCommitteeListFile,
            proposalFile: request.proposalFile,
            revisionExplanationFile: request.revisionExplanationFile,
            acceptanceDecisionFile: request.acceptanceDecisionFile,
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(requestWasSent, isFalse);
    });

    test('downloads bytes with response filename and bearer auth', () async {
      RequestOptions? captured;
      final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
        createStubDio(
          (_) => Uint8List.fromList([10, 20, 30]),
          capture: (options) => captured = options,
          responseHeaders: (_) => Headers.fromMap({
            Headers.contentTypeHeader: ['application/pdf'],
            'content-disposition': [
              "attachment; filename*=UTF-8''bi%C3%AAn-b%E1%BA%A3n.pdf",
            ],
          }),
        ),
      );

      final result = await dataSource.downloadFile(
        fileKey: ' reports/minutes.pdf ',
        yearId: ' YEAR-01 ',
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, '/researches/post-acceptance-reports/download');
      expect(captured!.queryParameters, {
        'fileKey': 'reports/minutes.pdf',
        'yearId': 'YEAR-01',
      });
      expect(captured!.responseType, ResponseType.bytes);
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(result.bytes, Uint8List.fromList([10, 20, 30]));
      expect(result.fileName, 'biên-bản.pdf');
      expect(result.contentType, 'application/pdf');
    });

    test(
      'uses file key basename when download header has no filename',
      () async {
        final dataSource = ResearchPostAcceptanceReportRemoteDataSource(
          createStubDio((_) => Uint8List.fromList([1])),
        );

        final result = await dataSource.downloadFile(
          fileKey: 'reports/decision.pdf',
          yearId: 'YEAR-01',
        );

        expect(result.fileName, 'decision.pdf');
      },
    );

    test('rejects malformed history and empty download responses', () async {
      final malformedHistoryDataSource =
          ResearchPostAcceptanceReportRemoteDataSource(
            createStubDio((_) => <Object?>[]),
          );
      final emptyDownloadDataSource =
          ResearchPostAcceptanceReportRemoteDataSource(
            createStubDio((_) => Uint8List(0)),
          );

      await expectLater(
        malformedHistoryDataSource.getReports(
          researchId: 'RESEARCH-01',
          yearId: 'YEAR-01',
        ),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        emptyDownloadDataSource.downloadFile(
          fileKey: 'reports/report.pdf',
          yearId: 'YEAR-01',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

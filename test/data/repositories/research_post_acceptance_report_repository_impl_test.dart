import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_post_acceptance_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/research_post_acceptance_report_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';

typedef _GetReportsCallback =
    Future<List<ResearchPostAcceptanceReport>> Function({
      required String researchId,
      required String yearId,
    });
typedef _UploadReportCallback =
    Future<void> Function({
      required ResearchPostAcceptanceReportRequest request,
      ProgressCallback? onSendProgress,
    });
typedef _DownloadFileCallback =
    Future<ResearchPostAcceptanceReportDownload> Function({
      required String fileKey,
      required String yearId,
    });

class _FakeRemoteDataSource extends Fake
    implements ResearchPostAcceptanceReportRemoteDataSource {
  _FakeRemoteDataSource({
    this.getReportsCallback,
    this.uploadReportCallback,
    this.downloadFileCallback,
  });

  final _GetReportsCallback? getReportsCallback;
  final _UploadReportCallback? uploadReportCallback;
  final _DownloadFileCallback? downloadFileCallback;

  @override
  Future<List<ResearchPostAcceptanceReport>> getReports({
    required String researchId,
    required String yearId,
  }) {
    return getReportsCallback!(researchId: researchId, yearId: yearId);
  }

  @override
  Future<void> uploadReport({
    required ResearchPostAcceptanceReportRequest request,
    ProgressCallback? onSendProgress,
  }) {
    return uploadReportCallback!(
      request: request,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<ResearchPostAcceptanceReportDownload> downloadFile({
    required String fileKey,
    required String yearId,
  }) {
    return downloadFileCallback!(fileKey: fileKey, yearId: yearId);
  }
}

DioException _dioError(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/researches/post-acceptance-reports'),
    type: type,
  );
}

ResearchPostAcceptanceUploadFile _file(String fileName) {
  return ResearchPostAcceptanceUploadFile(
    fileName: fileName,
    bytes: Uint8List.fromList([1]),
  );
}

ResearchPostAcceptanceReportRequest _request() {
  return ResearchPostAcceptanceReportRequest(
    researchId: 'RESEARCH-01',
    yearId: 'YEAR-01',
    submitterType: ResearchPostAcceptanceSubmitterType.student,
    reportFile: _file('report.pdf'),
    acceptanceMinutesFile: _file('minutes.pdf'),
    acceptanceCommitteeListFile: _file('committee.pdf'),
    proposalFile: _file('proposal.pdf'),
    revisionExplanationFile: _file('revision.pdf'),
    acceptanceDecisionFile: _file('decision.pdf'),
  );
}

void main() {
  const mapper = DioExceptionMapper();

  ResearchPostAcceptanceReportRepositoryImpl createRepository(
    _FakeRemoteDataSource remoteDataSource,
  ) {
    return ResearchPostAcceptanceReportRepositoryImpl(remoteDataSource, mapper);
  }

  group('ResearchPostAcceptanceReportRepositoryImpl', () {
    test('forwards report history parameters and returns result', () async {
      String? capturedResearchId;
      String? capturedYearId;
      const reports = <ResearchPostAcceptanceReport>[];
      final repository = createRepository(
        _FakeRemoteDataSource(
          getReportsCallback: ({required researchId, required yearId}) async {
            capturedResearchId = researchId;
            capturedYearId = yearId;
            return reports;
          },
        ),
      );

      final result = await repository.getReports(
        researchId: 'RESEARCH-01',
        yearId: 'YEAR-01',
      );

      expect(capturedResearchId, 'RESEARCH-01');
      expect(capturedYearId, 'YEAR-01');
      expect(result, same(reports));
    });

    test('forwards upload request and progress callback', () async {
      final request = _request();
      ResearchPostAcceptanceReportRequest? capturedRequest;
      ProgressCallback? capturedProgress;
      final repository = createRepository(
        _FakeRemoteDataSource(
          uploadReportCallback: ({required request, onSendProgress}) async {
            capturedRequest = request;
            capturedProgress = onSendProgress;
          },
        ),
      );
      void onProgress(int sent, int total) {}

      await repository.uploadReport(
        request: request,
        onSendProgress: onProgress,
      );

      expect(capturedRequest, same(request));
      expect(capturedProgress, same(onProgress));
    });

    test('forwards download parameters and returns downloaded file', () async {
      String? capturedFileKey;
      String? capturedYearId;
      final download = ResearchPostAcceptanceReportDownload(
        bytes: Uint8List.fromList([1, 2]),
        fileName: 'report.pdf',
        contentType: 'application/pdf',
      );
      final repository = createRepository(
        _FakeRemoteDataSource(
          downloadFileCallback: ({required fileKey, required yearId}) async {
            capturedFileKey = fileKey;
            capturedYearId = yearId;
            return download;
          },
        ),
      );

      final result = await repository.downloadFile(
        fileKey: 'reports/report.pdf',
        yearId: 'YEAR-01',
      );

      expect(capturedFileKey, 'reports/report.pdf');
      expect(capturedYearId, 'YEAR-01');
      expect(result, same(download));
    });

    test('maps Dio errors to AppException', () {
      final repository = createRepository(
        _FakeRemoteDataSource(
          getReportsCallback: ({required researchId, required yearId}) {
            throw _dioError(DioExceptionType.connectionTimeout);
          },
        ),
      );

      expect(
        () =>
            repository.getReports(researchId: 'RESEARCH-01', yearId: 'YEAR-01'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps malformed history to UnexpectedException', () {
      final repository = createRepository(
        _FakeRemoteDataSource(
          getReportsCallback: ({required researchId, required yearId}) {
            throw const FormatException('bad report history');
          },
        ),
      );

      expect(
        () =>
            repository.getReports(researchId: 'RESEARCH-01', yearId: 'YEAR-01'),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu báo cáo sau nghiệm thu không hợp lệ.',
          ),
        ),
      );
    });

    test('maps invalid upload request to UnexpectedException', () {
      final repository = createRepository(
        _FakeRemoteDataSource(
          uploadReportCallback: ({required request, onSendProgress}) {
            throw const FormatException('bad upload request');
          },
        ),
      );

      expect(
        () => repository.uploadReport(request: _request()),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Thông tin hoặc tệp báo cáo sau nghiệm thu không hợp lệ.',
          ),
        ),
      );
    });

    test('maps invalid download data to UnexpectedException', () {
      final repository = createRepository(
        _FakeRemoteDataSource(
          downloadFileCallback: ({required fileKey, required yearId}) {
            throw const FormatException('empty download');
          },
        ),
      );

      expect(
        () => repository.downloadFile(
          fileKey: 'reports/report.pdf',
          yearId: 'YEAR-01',
        ),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Thông tin hoặc dữ liệu tệp báo cáo sau nghiệm thu không hợp lệ.',
          ),
        ),
      );
    });
  });
}

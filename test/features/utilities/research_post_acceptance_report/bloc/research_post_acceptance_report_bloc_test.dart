import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_post_acceptance_report_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_post_acceptance_report/bloc/research_post_acceptance_report_bloc.dart';

class _MockResearchPostAcceptanceReportRepository extends Mock
    implements ResearchPostAcceptanceReportRepository {}

void main() {
  const researchId = 'research-1';
  const yearId = 'year-1';

  ResearchPostAcceptanceUploadFile uploadFile(String fileName) =>
      ResearchPostAcceptanceUploadFile(
        fileName: fileName,
        bytes: Uint8List.fromList(const [1, 2, 3]),
      );

  final request = ResearchPostAcceptanceReportRequest(
    researchId: researchId,
    yearId: yearId,
    submitterType: ResearchPostAcceptanceSubmitterType.student,
    reportFile: uploadFile('report.pdf'),
    acceptanceMinutesFile: uploadFile('acceptance-minutes.pdf'),
    acceptanceCommitteeListFile: uploadFile('committee-list.pdf'),
    proposalFile: uploadFile('proposal.pdf'),
    revisionExplanationFile: uploadFile('revision-explanation.pdf'),
    acceptanceDecisionFile: uploadFile('acceptance-decision.pdf'),
  );

  ResearchPostAcceptanceReportFile reportFile(String fileName) =>
      ResearchPostAcceptanceReportFile(
        fileName: fileName,
        fileKey: 'reports/$fileName',
        fileType: 'application/pdf',
        fileUrl: 'https://example.test/$fileName',
      );

  final report = ResearchPostAcceptanceReport(
    order: 1,
    researchId: researchId,
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
    reportFile: reportFile('report.pdf'),
    acceptanceMinutesFile: reportFile('acceptance-minutes.pdf'),
    acceptanceCommitteeListFile: reportFile('committee-list.pdf'),
    proposalFile: reportFile('proposal.pdf'),
    revisionExplanationFile: reportFile('revision-explanation.pdf'),
    acceptanceDecisionFile: reportFile('acceptance-decision.pdf'),
    submissionDate: DateTime.utc(2026, 3, 8),
    status: ResearchPostAcceptanceReportStatus.submitted,
  );

  final download = ResearchPostAcceptanceReportDownload(
    bytes: Uint8List.fromList(const [1, 2, 3]),
    fileName: 'report.pdf',
    contentType: 'application/pdf',
  );

  late _MockResearchPostAcceptanceReportRepository repository;

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    repository = _MockResearchPostAcceptanceReportRepository();
  });

  ResearchPostAcceptanceReportBloc buildBloc() =>
      ResearchPostAcceptanceReportBloc(repository: repository);

  group('ResearchPostAcceptanceReportBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ResearchPostAcceptanceReportState());
    });

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'loads reports with normalized identifiers',
      setUp: () {
        when(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).thenAnswer((_) async => [report]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchPostAcceptanceReportStarted(
          researchId: '  $researchId  ',
          yearId: '  $yearId  ',
        ),
      ),
      expect: () => [
        const ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.loading,
          researchId: researchId,
          yearId: yearId,
        ),
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          researchId: researchId,
          yearId: yearId,
          reports: [report],
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).called(1);
      },
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'rejects missing identifiers without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchPostAcceptanceReportStarted(
          researchId: ' ',
          yearId: yearId,
        ),
      ),
      expect: () => const [
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.failure,
          yearId: yearId,
          loadErrorMessage: 'Thiếu mã đề tài nghiên cứu.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.getReports(
            researchId: any(named: 'researchId'),
            yearId: any(named: 'yearId'),
          ),
        );
      },
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchPostAcceptanceReportStarted(
          researchId: researchId,
          yearId: yearId,
        ),
      ),
      expect: () => const [
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.loading,
          researchId: researchId,
          yearId: yearId,
        ),
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.failure,
          researchId: researchId,
          yearId: yearId,
          loadErrorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'uploads, reports progress, and reloads the current history',
      setUp: () {
        when(
          () => repository.uploadReport(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer((invocation) async {
          final onSendProgress =
              invocation.namedArguments[#onSendProgress]
                  as ResearchPostAcceptanceUploadProgressCallback?;
          onSendProgress?.call(1, 2);
          onSendProgress?.call(2, 2);
        });
        when(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).thenAnswer((_) async => [report]);
      },
      build: buildBloc,
      seed: () => const ResearchPostAcceptanceReportState(
        loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
        researchId: researchId,
        yearId: yearId,
      ),
      act: (bloc) =>
          bloc.add(ResearchPostAcceptanceReportUploaded(request: request)),
      expect: () => [
        const ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.uploading,
          researchId: researchId,
          yearId: yearId,
        ),
        const ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.uploading,
          researchId: researchId,
          yearId: yearId,
          uploadProgress: 0.5,
        ),
        const ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.uploading,
          researchId: researchId,
          yearId: yearId,
          uploadProgress: 1,
        ),
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.success,
          researchId: researchId,
          yearId: yearId,
          reports: [report],
          uploadProgress: 1,
          uploadMessage: 'Nộp báo cáo sau nghiệm thu thành công.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.uploadReport(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).called(1);
        verify(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).called(1);
      },
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'rejects a lecturer upload without paper',
      build: buildBloc,
      act: (bloc) => bloc.add(
        ResearchPostAcceptanceReportUploaded(
          request: ResearchPostAcceptanceReportRequest(
            researchId: researchId,
            yearId: yearId,
            submitterType: ResearchPostAcceptanceSubmitterType.lecturer,
            reportFile: uploadFile('report.pdf'),
            acceptanceMinutesFile: uploadFile('acceptance-minutes.pdf'),
            acceptanceCommitteeListFile: uploadFile('committee-list.pdf'),
            proposalFile: uploadFile('proposal.pdf'),
            revisionExplanationFile: uploadFile('revision-explanation.pdf'),
            acceptanceDecisionFile: uploadFile('acceptance-decision.pdf'),
          ),
        ),
      ),
      expect: () => const [
        ResearchPostAcceptanceReportState(
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.failure,
          uploadMessage: 'Giảng viên cần tải lên paper.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.uploadReport(
            request: any(named: 'request'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        );
      },
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'preserves AppException message when uploading fails',
      setUp: () {
        when(
          () => repository.uploadReport(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(const ValidationException('Đã hết hạn nộp báo cáo.'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(ResearchPostAcceptanceReportUploaded(request: request)),
      expect: () => const [
        ResearchPostAcceptanceReportState(
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.uploading,
        ),
        ResearchPostAcceptanceReportState(
          uploadStatus: ResearchPostAcceptanceReportUploadStatus.failure,
          uploadMessage: 'Đã hết hạn nộp báo cáo.',
        ),
      ],
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'downloads a file using the current year',
      setUp: () {
        when(
          () => repository.downloadFile(
            fileKey: 'reports/report.pdf',
            yearId: yearId,
          ),
        ).thenAnswer((_) async => download);
      },
      build: buildBloc,
      seed: () => const ResearchPostAcceptanceReportState(
        loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
        researchId: researchId,
        yearId: yearId,
      ),
      act: (bloc) => bloc.add(
        const ResearchPostAcceptanceReportFileDownloaded(
          fileKey: '  reports/report.pdf  ',
        ),
      ),
      expect: () => [
        const ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          downloadStatus:
              ResearchPostAcceptanceReportDownloadStatus.downloading,
          researchId: researchId,
          yearId: yearId,
          downloadingFileKey: 'reports/report.pdf',
        ),
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          downloadStatus: ResearchPostAcceptanceReportDownloadStatus.success,
          researchId: researchId,
          yearId: yearId,
          downloadedFile: download,
          downloadMessage: 'Tải file báo cáo thành công.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.downloadFile(
            fileKey: 'reports/report.pdf',
            yearId: yearId,
          ),
        ).called(1);
      },
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'rejects a download without file key',
      build: buildBloc,
      seed: () => const ResearchPostAcceptanceReportState(yearId: yearId),
      act: (bloc) => bloc.add(
        const ResearchPostAcceptanceReportFileDownloaded(fileKey: ' '),
      ),
      expect: () => const [
        ResearchPostAcceptanceReportState(
          downloadStatus: ResearchPostAcceptanceReportDownloadStatus.failure,
          yearId: yearId,
          downloadMessage: 'Thiếu thông tin file cần tải.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.downloadFile(
            fileKey: any(named: 'fileKey'),
            yearId: any(named: 'yearId'),
          ),
        );
      },
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'preserves AppException message when downloading fails',
      setUp: () {
        when(
          () => repository.downloadFile(
            fileKey: 'reports/report.pdf',
            yearId: yearId,
          ),
        ).thenThrow(const NetworkException('Không thể kết nối máy chủ.'));
      },
      build: buildBloc,
      seed: () => const ResearchPostAcceptanceReportState(yearId: yearId),
      act: (bloc) => bloc.add(
        const ResearchPostAcceptanceReportFileDownloaded(
          fileKey: 'reports/report.pdf',
        ),
      ),
      expect: () => const [
        ResearchPostAcceptanceReportState(
          downloadStatus:
              ResearchPostAcceptanceReportDownloadStatus.downloading,
          yearId: yearId,
          downloadingFileKey: 'reports/report.pdf',
        ),
        ResearchPostAcceptanceReportState(
          downloadStatus: ResearchPostAcceptanceReportDownloadStatus.failure,
          yearId: yearId,
          downloadMessage: 'Không thể kết nối máy chủ.',
        ),
      ],
    );

    blocTest<
      ResearchPostAcceptanceReportBloc,
      ResearchPostAcceptanceReportState
    >(
      'clears operation states without discarding loaded reports',
      build: buildBloc,
      seed: () => ResearchPostAcceptanceReportState(
        loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
        uploadStatus: ResearchPostAcceptanceReportUploadStatus.success,
        downloadStatus: ResearchPostAcceptanceReportDownloadStatus.success,
        researchId: researchId,
        yearId: yearId,
        reports: [report],
        uploadProgress: 1,
        downloadedFile: download,
        uploadMessage: 'Nộp báo cáo sau nghiệm thu thành công.',
        downloadMessage: 'Tải file báo cáo thành công.',
      ),
      act: (bloc) {
        bloc
          ..add(const ResearchPostAcceptanceReportUploadStateCleared())
          ..add(const ResearchPostAcceptanceReportDownloadStateCleared());
      },
      expect: () => [
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          downloadStatus: ResearchPostAcceptanceReportDownloadStatus.success,
          researchId: researchId,
          yearId: yearId,
          reports: [report],
          downloadedFile: download,
          downloadMessage: 'Tải file báo cáo thành công.',
        ),
        ResearchPostAcceptanceReportState(
          loadStatus: ResearchPostAcceptanceReportLoadStatus.success,
          researchId: researchId,
          yearId: yearId,
          reports: [report],
        ),
      ],
    );
  });
}

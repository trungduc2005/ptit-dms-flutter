import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_pre_acceptance_report_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/bloc/research_pre_acceptance_report_bloc.dart';

class _MockResearchPreAcceptanceReportRepository extends Mock
    implements ResearchPreAcceptanceReportRepository {}

void main() {
  const researchId = 'research-1';
  const yearId = 'year-1';

  final request = ResearchPreAcceptanceReportRequest(
    researchId: researchId,
    yearId: yearId,
    reportFile: ResearchPreAcceptanceUploadFile(
      fileName: 'report.pdf',
      bytes: Uint8List.fromList(const [1, 2, 3]),
    ),
    turnitinReportFile: ResearchPreAcceptanceUploadFile(
      fileName: 'turnitin.pdf',
      bytes: Uint8List.fromList(const [4, 5, 6]),
    ),
  );

  final report = ResearchPreAcceptanceReport(
    order: 1,
    researchId: researchId,
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
    reportFile: const ResearchPreAcceptanceReportFile(
      fileName: 'report.pdf',
      fileKey: 'reports/report.pdf',
      fileType: 'application/pdf',
    ),
    turnitinReportFile: const ResearchPreAcceptanceReportFile(
      fileName: 'turnitin.pdf',
      fileKey: 'reports/turnitin.pdf',
      fileType: 'application/pdf',
    ),
    submissionDate: DateTime.utc(2026, 3, 8),
    status: ResearchPreAcceptanceReportStatus.pending,
    comment: '',
  );

  late _MockResearchPreAcceptanceReportRepository repository;

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    repository = _MockResearchPreAcceptanceReportRepository();
  });

  ResearchPreAcceptanceReportBloc buildBloc() =>
      ResearchPreAcceptanceReportBloc(repository: repository);

  group('ResearchPreAcceptanceReportBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ResearchPreAcceptanceReportState());
    });

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
      'loads reports with normalized identifiers',
      setUp: () {
        when(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).thenAnswer((_) async => [report]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchPreAcceptanceReportStarted(
          researchId: '  $researchId  ',
          yearId: '  $yearId  ',
        ),
      ),
      expect: () => [
        const ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.loading,
          researchId: researchId,
          yearId: yearId,
        ),
        ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
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

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
      'rejects missing identifiers without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchPreAcceptanceReportStarted(
          researchId: ' ',
          yearId: yearId,
        ),
      ),
      expect: () => const [
        ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.failure,
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

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchPreAcceptanceReportStarted(
          researchId: researchId,
          yearId: yearId,
        ),
      ),
      expect: () => const [
        ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.loading,
          researchId: researchId,
          yearId: yearId,
        ),
        ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.failure,
          researchId: researchId,
          yearId: yearId,
          loadErrorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
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
                  as ResearchPreAcceptanceUploadProgressCallback?;
          onSendProgress?.call(1, 2);
          onSendProgress?.call(2, 2);
        });
        when(
          () => repository.getReports(researchId: researchId, yearId: yearId),
        ).thenAnswer((_) async => [report]);
      },
      build: buildBloc,
      seed: () => const ResearchPreAcceptanceReportState(
        loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
        researchId: researchId,
        yearId: yearId,
      ),
      act: (bloc) =>
          bloc.add(ResearchPreAcceptanceReportUploaded(request: request)),
      expect: () => [
        const ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.uploading,
          researchId: researchId,
          yearId: yearId,
        ),
        const ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.uploading,
          researchId: researchId,
          yearId: yearId,
          uploadProgress: 0.5,
        ),
        const ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.uploading,
          researchId: researchId,
          yearId: yearId,
          uploadProgress: 1,
        ),
        ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.success,
          researchId: researchId,
          yearId: yearId,
          reports: [report],
          uploadProgress: 1,
          uploadMessage: 'Nộp báo cáo trước nghiệm thu thành công.',
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

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
      'rejects an invalid upload request without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        ResearchPreAcceptanceReportUploaded(
          request: ResearchPreAcceptanceReportRequest(
            researchId: researchId,
            yearId: yearId,
            reportFile: ResearchPreAcceptanceUploadFile(
              fileName: 'report.txt',
              bytes: Uint8List.fromList(const [1]),
            ),
            turnitinReportFile: ResearchPreAcceptanceUploadFile(
              fileName: 'turnitin.pdf',
              bytes: Uint8List.fromList(const [1]),
            ),
          ),
        ),
      ),
      expect: () => const [
        ResearchPreAcceptanceReportState(
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.failure,
          uploadMessage: 'quyển báo cáo phải có định dạng PDF, DOC hoặc DOCX.',
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

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
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
          bloc.add(ResearchPreAcceptanceReportUploaded(request: request)),
      expect: () => const [
        ResearchPreAcceptanceReportState(
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.uploading,
        ),
        ResearchPreAcceptanceReportState(
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.failure,
          uploadMessage: 'Đã hết hạn nộp báo cáo.',
        ),
      ],
    );

    blocTest<ResearchPreAcceptanceReportBloc, ResearchPreAcceptanceReportState>(
      'clears upload state without discarding loaded reports',
      build: buildBloc,
      seed: () => ResearchPreAcceptanceReportState(
        loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
        uploadStatus: ResearchPreAcceptanceReportUploadStatus.success,
        researchId: researchId,
        yearId: yearId,
        reports: [report],
        uploadProgress: 1,
        uploadMessage: 'Nộp báo cáo trước nghiệm thu thành công.',
      ),
      act: (bloc) =>
          bloc.add(const ResearchPreAcceptanceReportUploadStateCleared()),
      expect: () => [
        ResearchPreAcceptanceReportState(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
          researchId: researchId,
          yearId: yearId,
          reports: [report],
        ),
      ],
    );
  });
}

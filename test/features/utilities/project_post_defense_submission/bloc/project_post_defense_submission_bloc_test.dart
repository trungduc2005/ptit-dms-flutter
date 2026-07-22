import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_post_defense_submission_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_post_defense_submission/bloc/project_post_defense_submission_bloc.dart';

class _MockProjectPostDefenseSubmissionRepository extends Mock
    implements ProjectPostDefenseSubmissionRepository {}

void main() {
  const projectId = 'project-1';
  const academicYearId = 'academic-year-1';

  final request = ProjectPostDefenseSubmissionRequest(
    projectId: projectId,
    academicYearId: academicYearId,
    thesisFile: ProjectPostDefenseUploadFile(
      fileName: 'do-an.pdf',
      bytes: Uint8List.fromList([1]),
    ),
    responseCommitteeFile: ProjectPostDefenseUploadFile(
      fileName: 'giai-trinh.docx',
      bytes: Uint8List.fromList([2]),
    ),
    approvalMinutesFile: ProjectPostDefenseUploadFile(
      fileName: 'bien-ban.pdf',
      bytes: Uint8List.fromList([3]),
    ),
    sourceFile: ProjectPostDefenseUploadFile(
      fileName: 'san-pham.zip',
      bytes: Uint8List.fromList([4]),
    ),
  );

  const emptySubmission = ProjectPostDefenseSubmission(submissions: []);

  const submittedSubmission = ProjectPostDefenseSubmission(
    guiderApprovalStatus: ProjectPostDefenseSubmissionStatus.pending,
    committeeApprovalStatus: ProjectPostDefenseSubmissionStatus.pending,
    submissions: [
      ProjectPostDefenseSubmissionAttempt(
        files: [
          ProjectPostDefenseFile(
            fileName: 'do-an.pdf',
            fileKey: 'projects/do-an.pdf',
            fileType: 'thesis',
          ),
        ],
        guiderApproval: ProjectPostDefenseApproval(
          status: ProjectPostDefenseSubmissionStatus.pending,
        ),
        committeeApproval: ProjectPostDefenseApproval(
          status: ProjectPostDefenseSubmissionStatus.pending,
        ),
      ),
    ],
  );

  late _MockProjectPostDefenseSubmissionRepository repository;

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    repository = _MockProjectPostDefenseSubmissionRepository();
  });

  ProjectPostDefenseSubmissionBloc buildBloc() =>
      ProjectPostDefenseSubmissionBloc(repository: repository);

  group('ProjectPostDefenseSubmissionBloc', () {
    test('has the expected initial state and derived values', () {
      final state = buildBloc().state;

      expect(state, const ProjectPostDefenseSubmissionState());
      expect(state.isBusy, isFalse);
      expect(state.hasSubmitted, isFalse);
      expect(state.canUpload, isTrue);
      expect(state.isFullyApproved, isFalse);
    });

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'loads submission with normalized identifiers',
      setUp: () {
        when(
          () => repository.getSubmission(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).thenAnswer((_) async => emptySubmission);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectPostDefenseSubmissionStarted(
          projectId: '  $projectId  ',
          academicYearId: '  $academicYearId  ',
        ),
      ),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.loading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.success,
          projectId: projectId,
          academicYearId: academicYearId,
          submission: emptySubmission,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getSubmission(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).called(1);
      },
    );

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'rejects invalid load identifiers without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectPostDefenseSubmissionStarted(
          projectId: ' ',
          academicYearId: academicYearId,
        ),
      ),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.failure,
          academicYearId: academicYearId,
          loadErrorMessage: 'Thiếu mã đồ án.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.getSubmission(
          projectId: any(named: 'projectId'),
          academicYearId: any(named: 'academicYearId'),
        ),
      ),
    );

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getSubmission(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectPostDefenseSubmissionStarted(
          projectId: projectId,
          academicYearId: academicYearId,
        ),
      ),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.loading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.failure,
          projectId: projectId,
          academicYearId: academicYearId,
          loadErrorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'uploads, reports progress, and reloads latest submission',
      setUp: () {
        when(
          () => repository.uploadSubmission(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onSendProgress]
                  as ProjectPostDefenseUploadProgressCallback;
          onProgress(25, 100);
          onProgress(100, 100);
        });
        when(
          () => repository.getSubmission(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).thenAnswer((_) async => submittedSubmission);
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(ProjectPostDefenseSubmissionUploaded(request: request)),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPostDefenseSubmissionState(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
          uploadProgress: 0.25,
        ),
        ProjectPostDefenseSubmissionState(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
          uploadProgress: 1,
        ),
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.success,
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.success,
          projectId: projectId,
          academicYearId: academicYearId,
          submission: submittedSubmission,
          uploadProgress: 1,
          uploadMessage: 'Nộp đồ án sau bảo vệ thành công.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.uploadSubmission(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).called(1);
        verify(
          () => repository.getSubmission(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ).called(1);
      },
    );

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'rejects invalid upload request without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        ProjectPostDefenseSubmissionUploaded(
          request: ProjectPostDefenseSubmissionRequest(
            projectId: projectId,
            academicYearId: academicYearId,
            thesisFile: ProjectPostDefenseUploadFile(
              fileName: 'do-an.txt',
              bytes: Uint8List.fromList([1]),
            ),
            responseCommitteeFile: ProjectPostDefenseUploadFile(
              fileName: 'giai-trinh.pdf',
              bytes: Uint8List.fromList([2]),
            ),
            approvalMinutesFile: ProjectPostDefenseUploadFile(
              fileName: 'bien-ban.pdf',
              bytes: Uint8List.fromList([3]),
            ),
            sourceFile: ProjectPostDefenseUploadFile(
              fileName: 'san-pham.zip',
              bytes: Uint8List.fromList([4]),
            ),
          ),
        ),
      ),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.failure,
          uploadMessage:
              'file quyển đồ án phải có định dạng PDF, DOC hoặc DOCX.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.uploadSubmission(
          request: any(named: 'request'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ),
    );

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'preserves AppException message when upload fails',
      setUp: () {
        when(
          () => repository.uploadSubmission(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(const ValidationException('Đã hết hạn nộp đồ án.'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(ProjectPostDefenseSubmissionUploaded(request: request)),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPostDefenseSubmissionState(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.failure,
          projectId: projectId,
          academicYearId: academicYearId,
          uploadMessage: 'Đã hết hạn nộp đồ án.',
        ),
      ],
    );

    blocTest<
      ProjectPostDefenseSubmissionBloc,
      ProjectPostDefenseSubmissionState
    >(
      'clears upload state without discarding loaded submission',
      build: buildBloc,
      seed: () => const ProjectPostDefenseSubmissionState(
        loadStatus: ProjectPostDefenseSubmissionLoadStatus.success,
        uploadStatus: ProjectPostDefenseSubmissionUploadStatus.success,
        projectId: projectId,
        academicYearId: academicYearId,
        submission: submittedSubmission,
        uploadProgress: 1,
        uploadMessage: 'Nộp đồ án sau bảo vệ thành công.',
      ),
      act: (bloc) =>
          bloc.add(const ProjectPostDefenseSubmissionUploadStateCleared()),
      expect: () => const [
        ProjectPostDefenseSubmissionState(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.success,
          projectId: projectId,
          academicYearId: academicYearId,
          submission: submittedSubmission,
        ),
      ],
    );
  });
}

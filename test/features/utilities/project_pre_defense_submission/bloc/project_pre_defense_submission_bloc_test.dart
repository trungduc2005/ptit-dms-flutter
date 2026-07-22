import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_pre_defense_submission_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_pre_defense_submission/bloc/project_pre_defense_submission_bloc.dart';

class _MockProjectPreDefenseSubmissionRepository extends Mock
    implements ProjectPreDefenseSubmissionRepository {}

void main() {
  const projectId = 'project-1';
  const academicYearId = 'academic-year-1';

  final request = ProjectPreDefenseSubmissionRequest(
    projectId: projectId,
    academicYearId: academicYearId,
    thesisFile: ProjectPreDefenseUploadFile(
      fileName: 'do-an.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    ),
  );

  const emptySubmission = ProjectPreDefenseSubmission(submissions: []);

  const submittedSubmission = ProjectPreDefenseSubmission(
    status: ProjectPreDefenseSubmissionStatus.pending,
    submissions: [
      ProjectPreDefenseSubmissionAttempt(
        files: [
          ProjectPreDefenseFile(
            fileName: 'do-an.pdf',
            fileKey: 'projects/do-an.pdf',
            fileType: 'thesis',
          ),
        ],
        guiderApproval: ProjectPreDefenseApproval(
          status: ProjectPreDefenseSubmissionStatus.pending,
        ),
      ),
    ],
  );

  late _MockProjectPreDefenseSubmissionRepository repository;

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    repository = _MockProjectPreDefenseSubmissionRepository();
  });

  ProjectPreDefenseSubmissionBloc buildBloc() =>
      ProjectPreDefenseSubmissionBloc(repository: repository);

  group('ProjectPreDefenseSubmissionBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ProjectPreDefenseSubmissionState());
    });

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
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
        const ProjectPreDefenseSubmissionStarted(
          projectId: '  $projectId  ',
          academicYearId: '  $academicYearId  ',
        ),
      ),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.loading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.success,
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

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
      'rejects invalid load identifiers without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectPreDefenseSubmissionStarted(
          projectId: ' ',
          academicYearId: academicYearId,
        ),
      ),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.failure,
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

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
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
        const ProjectPreDefenseSubmissionStarted(
          projectId: projectId,
          academicYearId: academicYearId,
        ),
      ),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.loading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.failure,
          projectId: projectId,
          academicYearId: academicYearId,
          loadErrorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
      'uploads, reports progress, and reloads the latest submission',
      setUp: () {
        when(
          () => repository.uploadSubmission(
            request: request,
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onSendProgress]
                  as ProjectUploadProgressCallback;
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
          bloc.add(ProjectPreDefenseSubmissionUploaded(request: request)),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPreDefenseSubmissionState(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
          uploadProgress: 0.25,
        ),
        ProjectPreDefenseSubmissionState(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
          uploadProgress: 1,
        ),
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.success,
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.success,
          projectId: projectId,
          academicYearId: academicYearId,
          submission: submittedSubmission,
          uploadProgress: 1,
          uploadMessage: 'Nộp đồ án trước bảo vệ thành công.',
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

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
      'rejects an invalid upload request without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectPreDefenseSubmissionUploaded(
          request: ProjectPreDefenseSubmissionRequest(
            projectId: projectId,
            academicYearId: academicYearId,
          ),
        ),
      ),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.failure,
          uploadMessage: 'Cần chọn ít nhất một file để nộp.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.uploadSubmission(
          request: any(named: 'request'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ),
    );

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
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
          bloc.add(ProjectPreDefenseSubmissionUploaded(request: request)),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.uploading,
          projectId: projectId,
          academicYearId: academicYearId,
        ),
        ProjectPreDefenseSubmissionState(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.failure,
          projectId: projectId,
          academicYearId: academicYearId,
          uploadMessage: 'Đã hết hạn nộp đồ án.',
        ),
      ],
    );

    blocTest<ProjectPreDefenseSubmissionBloc, ProjectPreDefenseSubmissionState>(
      'clears upload state without discarding loaded submission',
      build: buildBloc,
      seed: () => const ProjectPreDefenseSubmissionState(
        loadStatus: ProjectPreDefenseSubmissionLoadStatus.success,
        uploadStatus: ProjectPreDefenseSubmissionUploadStatus.success,
        projectId: projectId,
        academicYearId: academicYearId,
        submission: submittedSubmission,
        uploadProgress: 1,
        uploadMessage: 'Nộp đồ án trước bảo vệ thành công.',
      ),
      act: (bloc) =>
          bloc.add(const ProjectPreDefenseSubmissionUploadStateCleared()),
      expect: () => const [
        ProjectPreDefenseSubmissionState(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.success,
          projectId: projectId,
          academicYearId: academicYearId,
          submission: submittedSubmission,
        ),
      ],
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_result_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_result/bloc/project_result_bloc.dart';

class _MockProjectResultRepository extends Mock
    implements ProjectResultRepository {}

const _projectId = 'project-1';
const _academicYearId = 'academic-year-1';

const _publishedResult = ProjectResult(
  projectId: _projectId,
  projectName: 'Đồ án mẫu',
  members: [
    ProjectResultMember(
      studentId: 'B20DCCN001',
      fullName: 'Nguyễn Văn A',
      clos: [
        ProjectCloResult(
          cloId: 'clo-1',
          cloName: 'CLO 1',
          cloDescription: 'Chuẩn đầu ra 1',
          cloWeight: 0.5,
          average: 8,
        ),
      ],
      totalGpa: 8,
    ),
  ],
);

const _unpublishedResult = ProjectResult(
  projectId: _projectId,
  projectName: 'Đồ án mẫu',
  members: [],
);

void main() {
  late _MockProjectResultRepository repository;

  setUp(() {
    repository = _MockProjectResultRepository();
  });

  ProjectResultBloc buildBloc() => ProjectResultBloc(repository);

  group('ProjectResultBloc', () {
    test('initial state is ProjectResultState()', () {
      expect(buildBloc().state, const ProjectResultState());
    });

    group('ProjectResultStarted', () {
      blocTest<ProjectResultBloc, ProjectResultState>(
        'emits loading then success with the returned result',
        setUp: () {
          when(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _publishedResult);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectResultStarted(
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
        ),
        expect: () => const [
          ProjectResultState(
            status: ProjectResultStatus.loading,
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
          ProjectResultState(
            status: ProjectResultStatus.success,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _publishedResult,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).called(1);
        },
      );

      blocTest<ProjectResultBloc, ProjectResultState>(
        'treats an unpublished result as success',
        setUp: () {
          when(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _unpublishedResult);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectResultStarted(
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
        ),
        expect: () => const [
          ProjectResultState(
            status: ProjectResultStatus.loading,
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
          ProjectResultState(
            status: ProjectResultStatus.success,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _unpublishedResult,
          ),
        ],
      );

      blocTest<ProjectResultBloc, ProjectResultState>(
        'emits loading then failure with AppException message',
        setUp: () {
          when(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).thenThrow(NetworkException('Không có kết nối mạng'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectResultStarted(
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
        ),
        expect: () => const [
          ProjectResultState(
            status: ProjectResultStatus.loading,
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
          ProjectResultState(
            status: ProjectResultStatus.failure,
            projectId: _projectId,
            academicYearId: _academicYearId,
            errorMessage: 'Không có kết nối mạng',
          ),
        ],
      );

      blocTest<ProjectResultBloc, ProjectResultState>(
        'clears stale result when loading a different project',
        setUp: () {
          when(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _publishedResult);
        },
        build: buildBloc,
        seed: () => const ProjectResultState(
          status: ProjectResultStatus.success,
          projectId: 'old-project',
          academicYearId: 'old-academic-year',
          result: _publishedResult,
        ),
        act: (bloc) => bloc.add(
          const ProjectResultStarted(
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
        ),
        expect: () => const [
          ProjectResultState(
            status: ProjectResultStatus.loading,
            projectId: _projectId,
            academicYearId: _academicYearId,
          ),
          ProjectResultState(
            status: ProjectResultStatus.success,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _publishedResult,
          ),
        ],
      );
    });

    group('ProjectResultRefreshed', () {
      blocTest<ProjectResultBloc, ProjectResultState>(
        'does nothing when no project and academic year have been loaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectResultRefreshed()),
        expect: () => <ProjectResultState>[],
        verify: (_) {
          verifyNever(
            () => repository.getProjectResult(
              projectId: any(named: 'projectId'),
              academicYearId: any(named: 'academicYearId'),
            ),
          );
        },
      );

      blocTest<ProjectResultBloc, ProjectResultState>(
        'keeps current result while refreshing then emits success',
        setUp: () {
          when(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _publishedResult);
        },
        build: buildBloc,
        seed: () => const ProjectResultState(
          status: ProjectResultStatus.success,
          projectId: _projectId,
          academicYearId: _academicYearId,
          result: _publishedResult,
        ),
        act: (bloc) => bloc.add(const ProjectResultRefreshed()),
        expect: () => const [
          ProjectResultState(
            status: ProjectResultStatus.loading,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _publishedResult,
          ),
          ProjectResultState(
            status: ProjectResultStatus.success,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _publishedResult,
          ),
        ],
      );

      blocTest<ProjectResultBloc, ProjectResultState>(
        'keeps current result when refresh fails',
        setUp: () {
          when(
            () => repository.getProjectResult(
              projectId: _projectId,
              academicYearId: _academicYearId,
            ),
          ).thenThrow(ServerException('Không thể tải kết quả đồ án'));
        },
        build: buildBloc,
        seed: () => const ProjectResultState(
          status: ProjectResultStatus.success,
          projectId: _projectId,
          academicYearId: _academicYearId,
          result: _publishedResult,
        ),
        act: (bloc) => bloc.add(const ProjectResultRefreshed()),
        expect: () => const [
          ProjectResultState(
            status: ProjectResultStatus.loading,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _publishedResult,
          ),
          ProjectResultState(
            status: ProjectResultStatus.failure,
            projectId: _projectId,
            academicYearId: _academicYearId,
            result: _publishedResult,
            errorMessage: 'Không thể tải kết quả đồ án',
          ),
        ],
      );
    });

    group('ProjectResultState', () {
      test('helpers reflect result availability and publication status', () {
        expect(const ProjectResultState().hasResult, isFalse);
        expect(const ProjectResultState().isPublished, isFalse);
        expect(
          const ProjectResultState(result: _unpublishedResult).hasResult,
          isTrue,
        );
        expect(
          const ProjectResultState(result: _unpublishedResult).isPublished,
          isFalse,
        );
        expect(
          const ProjectResultState(result: _publishedResult).isPublished,
          isTrue,
        );
      });

      test('copyWith can explicitly clear nullable values', () {
        const state = ProjectResultState(
          result: _publishedResult,
          errorMessage: 'old error',
        );

        // ignore: avoid_redundant_argument_values
        final updated = state.copyWith(result: null, errorMessage: null);

        expect(updated.result, isNull);
        expect(updated.errorMessage, isNull);
      });
    });
  });
}

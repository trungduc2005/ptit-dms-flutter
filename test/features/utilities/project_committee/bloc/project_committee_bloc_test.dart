import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_committee_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_committee/bloc/project_committee_bloc.dart';

class _MockProjectCommitteeRepository extends Mock
    implements ProjectCommitteeRepository {}

const _academicYearId = 'academic-year-1';

const _committee = ProjectCommittee(
  committeeId: 'committee-1',
  name: 'Hội đồng 1',
  members: [
    ProjectCommitteeMember(
      memberId: 'lecturer-1',
      memberName: 'Nguyễn Văn A',
      department: 'Công nghệ thông tin',
      role: 'Chủ tịch',
    ),
  ],
  academicYear: '2024-2025',
  project: ProjectCommitteeProject(
    id: 'project-ref-1',
    projectId: 'project-1',
    projectName: 'Đồ án mẫu',
    members: [
      ProjectCommitteeStudent(
        studentRef: 'student-ref-1',
        studentId: 'B20DCCN001',
        studentName: 'Trần Văn B',
        role: 'LEADER',
      ),
    ],
    presentationOrder: 1,
  ),
);

void main() {
  late _MockProjectCommitteeRepository repository;

  setUp(() {
    repository = _MockProjectCommitteeRepository();
  });

  ProjectCommitteeBloc buildBloc() => ProjectCommitteeBloc(repository);

  group('ProjectCommitteeBloc', () {
    test('initial state is ProjectCommitteeState()', () {
      expect(buildBloc().state, const ProjectCommitteeState());
    });

    group('ProjectCommitteeStarted', () {
      blocTest<ProjectCommitteeBloc, ProjectCommitteeState>(
        'emits loading then success with the returned committee',
        setUp: () {
          when(
            () => repository.getMyProjectCommittee(
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _committee);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectCommitteeStarted(academicYearId: _academicYearId),
        ),
        expect: () => const [
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.loading,
            academicYearId: _academicYearId,
          ),
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.success,
            academicYearId: _academicYearId,
            committee: _committee,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.getMyProjectCommittee(
              academicYearId: _academicYearId,
            ),
          ).called(1);
        },
      );

      blocTest<ProjectCommitteeBloc, ProjectCommitteeState>(
        'emits loading then failure with AppException message',
        setUp: () {
          when(
            () => repository.getMyProjectCommittee(
              academicYearId: _academicYearId,
            ),
          ).thenThrow(NetworkException('Không có kết nối mạng'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProjectCommitteeStarted(academicYearId: _academicYearId),
        ),
        expect: () => const [
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.loading,
            academicYearId: _academicYearId,
          ),
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.failure,
            academicYearId: _academicYearId,
            errorMessage: 'Không có kết nối mạng',
          ),
        ],
      );

      blocTest<ProjectCommitteeBloc, ProjectCommitteeState>(
        'clears stale committee when loading a different academic year',
        setUp: () {
          when(
            () => repository.getMyProjectCommittee(
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _committee);
        },
        build: buildBloc,
        seed: () => const ProjectCommitteeState(
          status: ProjectCommitteeStatus.success,
          academicYearId: 'old-year',
          committee: _committee,
        ),
        act: (bloc) => bloc.add(
          const ProjectCommitteeStarted(academicYearId: _academicYearId),
        ),
        expect: () => const [
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.loading,
            academicYearId: _academicYearId,
          ),
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.success,
            academicYearId: _academicYearId,
            committee: _committee,
          ),
        ],
      );
    });

    group('ProjectCommitteeRefreshed', () {
      blocTest<ProjectCommitteeBloc, ProjectCommitteeState>(
        'does nothing when no academic year has been loaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectCommitteeRefreshed()),
        expect: () => <ProjectCommitteeState>[],
        verify: (_) {
          verifyNever(
            () => repository.getMyProjectCommittee(
              academicYearId: any(named: 'academicYearId'),
            ),
          );
        },
      );

      blocTest<ProjectCommitteeBloc, ProjectCommitteeState>(
        'keeps current committee while refreshing then emits success',
        setUp: () {
          when(
            () => repository.getMyProjectCommittee(
              academicYearId: _academicYearId,
            ),
          ).thenAnswer((_) async => _committee);
        },
        build: buildBloc,
        seed: () => const ProjectCommitteeState(
          status: ProjectCommitteeStatus.success,
          academicYearId: _academicYearId,
          committee: _committee,
        ),
        act: (bloc) => bloc.add(const ProjectCommitteeRefreshed()),
        expect: () => const [
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.loading,
            academicYearId: _academicYearId,
            committee: _committee,
          ),
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.success,
            academicYearId: _academicYearId,
            committee: _committee,
          ),
        ],
      );

      blocTest<ProjectCommitteeBloc, ProjectCommitteeState>(
        'keeps current committee when refresh fails',
        setUp: () {
          when(
            () => repository.getMyProjectCommittee(
              academicYearId: _academicYearId,
            ),
          ).thenThrow(ServerException('Không thể tải hội đồng'));
        },
        build: buildBloc,
        seed: () => const ProjectCommitteeState(
          status: ProjectCommitteeStatus.success,
          academicYearId: _academicYearId,
          committee: _committee,
        ),
        act: (bloc) => bloc.add(const ProjectCommitteeRefreshed()),
        expect: () => const [
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.loading,
            academicYearId: _academicYearId,
            committee: _committee,
          ),
          ProjectCommitteeState(
            status: ProjectCommitteeStatus.failure,
            academicYearId: _academicYearId,
            committee: _committee,
            errorMessage: 'Không thể tải hội đồng',
          ),
        ],
      );
    });

    group('ProjectCommitteeState', () {
      test('hasCommittee reflects committee availability', () {
        expect(const ProjectCommitteeState().hasCommittee, isFalse);
        expect(
          const ProjectCommitteeState(committee: _committee).hasCommittee,
          isTrue,
        );
      });

      test('copyWith can explicitly clear nullable values', () {
        const state = ProjectCommitteeState(
          committee: _committee,
          errorMessage: 'old error',
        );

        // ignore: avoid_redundant_argument_values
        final updated = state.copyWith(committee: null, errorMessage: null);

        expect(updated.committee, isNull);
        expect(updated.errorMessage, isNull);
      });
    });
  });
}

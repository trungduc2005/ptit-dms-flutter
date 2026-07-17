import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/membership_response/project_membership_response_bloc.dart';

class _MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  const projectId = 'project-1';
  const studentRef = 'student-ref-1';

  late _MockProjectRepository repository;

  setUp(() {
    repository = _MockProjectRepository();
  });

  ProjectMembershipResponseBloc buildBloc() =>
      ProjectMembershipResponseBloc(projectRepository: repository);

  group('ProjectMembershipResponseBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ProjectMembershipResponseState());
    });

    blocTest<ProjectMembershipResponseBloc, ProjectMembershipResponseState>(
      'approves membership and emits submitting then success',
      setUp: () {
        when(
          () => repository.approveProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
          ),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectMembershipApproved(
          projectId: projectId,
          studentRef: studentRef,
        ),
      ),
      expect: () => const [
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.submitting,
          action: ProjectMembershipResponseAction.approve,
        ),
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.success,
          action: ProjectMembershipResponseAction.approve,
          message: 'Bạn đã xác nhận tham gia nhóm đồ án.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.approveProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
          ),
        ).called(1);
      },
    );

    blocTest<ProjectMembershipResponseBloc, ProjectMembershipResponseState>(
      'rejects membership and trims the provided reason',
      setUp: () {
        when(
          () => repository.rejectProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
            reason: 'Đã có nhóm khác',
          ),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectMembershipRejected(
          projectId: projectId,
          studentRef: studentRef,
          reason: '  Đã có nhóm khác  ',
        ),
      ),
      expect: () => const [
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.submitting,
          action: ProjectMembershipResponseAction.reject,
        ),
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.success,
          action: ProjectMembershipResponseAction.reject,
          message: 'Bạn đã từ chối tham gia nhóm đồ án.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.rejectProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
            reason: 'Đã có nhóm khác',
          ),
        ).called(1);
      },
    );

    blocTest<ProjectMembershipResponseBloc, ProjectMembershipResponseState>(
      'converts a blank rejection reason to null',
      setUp: () {
        when(
          () => repository.rejectProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
          ),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectMembershipRejected(
          projectId: projectId,
          studentRef: studentRef,
          reason: '   ',
        ),
      ),
      expect: () => const [
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.submitting,
          action: ProjectMembershipResponseAction.reject,
        ),
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.success,
          action: ProjectMembershipResponseAction.reject,
          message: 'Bạn đã từ chối tham gia nhóm đồ án.',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.rejectProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
          ),
        ).called(1);
      },
    );

    blocTest<ProjectMembershipResponseBloc, ProjectMembershipResponseState>(
      'preserves the AppException message when approval fails',
      setUp: () {
        when(
          () => repository.approveProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
          ),
        ).thenThrow(const ValidationException('Lời mời không còn hiệu lực.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectMembershipApproved(
          projectId: projectId,
          studentRef: studentRef,
        ),
      ),
      expect: () => const [
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.submitting,
          action: ProjectMembershipResponseAction.approve,
        ),
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.failure,
          action: ProjectMembershipResponseAction.approve,
          message: 'Lời mời không còn hiệu lực.',
        ),
      ],
    );

    blocTest<ProjectMembershipResponseBloc, ProjectMembershipResponseState>(
      'uses a safe fallback message when rejection throws an unknown error',
      setUp: () {
        when(
          () => repository.rejectProjectMembership(
            projectId: projectId,
            studentRef: studentRef,
            reason: any(named: 'reason'),
          ),
        ).thenThrow(StateError('unexpected'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProjectMembershipRejected(
          projectId: projectId,
          studentRef: studentRef,
          reason: 'Không tham gia',
        ),
      ),
      expect: () => const [
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.submitting,
          action: ProjectMembershipResponseAction.reject,
        ),
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.failure,
          action: ProjectMembershipResponseAction.reject,
          message: 'Không thể từ chối lời mời. Vui lòng thử lại.',
        ),
      ],
    );
  });
}

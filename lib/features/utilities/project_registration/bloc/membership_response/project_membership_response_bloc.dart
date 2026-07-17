import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';

import 'project_membership_response_event.dart';
import 'project_membership_response_state.dart';

export 'project_membership_response_event.dart';
export 'project_membership_response_state.dart';

class ProjectMembershipResponseBloc
    extends
        Bloc<ProjectMembershipResponseEvent, ProjectMembershipResponseState> {
  ProjectMembershipResponseBloc({required ProjectRepository projectRepository})
    : _projectRepository = projectRepository,
      super(const ProjectMembershipResponseState()) {
    on<ProjectMembershipApproved>(_onApproved);
    on<ProjectMembershipRejected>(_onRejected);
  }

  final ProjectRepository _projectRepository;

  Future<void> _onApproved(
    ProjectMembershipApproved event,
    Emitter<ProjectMembershipResponseState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(
      const ProjectMembershipResponseState(
        status: ProjectMembershipResponseStatus.submitting,
        action: ProjectMembershipResponseAction.approve,
      ),
    );

    try {
      await _projectRepository.approveProjectMembership(
        projectId: event.projectId,
        studentRef: event.studentRef,
      );

      if (emit.isDone || isClosed) return;
      emit(
        const ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.success,
          action: ProjectMembershipResponseAction.approve,
          message: 'Bạn đã xác nhận tham gia nhóm đồ án.',
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.failure,
          action: ProjectMembershipResponseAction.approve,
          message: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        const ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.failure,
          action: ProjectMembershipResponseAction.approve,
          message: 'Không thể xác nhận tham gia nhóm. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> _onRejected(
    ProjectMembershipRejected event,
    Emitter<ProjectMembershipResponseState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(
      const ProjectMembershipResponseState(
        status: ProjectMembershipResponseStatus.submitting,
        action: ProjectMembershipResponseAction.reject,
      ),
    );

    try {
      final trimmedReason = event.reason?.trim();
      await _projectRepository.rejectProjectMembership(
        projectId: event.projectId,
        studentRef: event.studentRef,
        reason: trimmedReason?.isNotEmpty == true ? trimmedReason : null,
      );

      if (emit.isDone || isClosed) return;
      emit(
        const ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.success,
          action: ProjectMembershipResponseAction.reject,
          message: 'Bạn đã từ chối tham gia nhóm đồ án.',
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.failure,
          action: ProjectMembershipResponseAction.reject,
          message: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        const ProjectMembershipResponseState(
          status: ProjectMembershipResponseStatus.failure,
          action: ProjectMembershipResponseAction.reject,
          message: 'Không thể từ chối lời mời. Vui lòng thử lại.',
        ),
      );
    }
  }
}

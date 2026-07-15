import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';

import 'project_registration_submit_event.dart';
import 'project_registration_submit_state.dart';

export 'project_registration_submit_event.dart';
export 'project_registration_submit_state.dart';

class ProjectRegistrationSubmitBloc
    extends Bloc<
      ProjectRegistrationSubmitEvent,
      ProjectRegistrationSubmitState
    > {
  ProjectRegistrationSubmitBloc({
    required ProjectRepository projectRepository,
  }) : _projectRepository = projectRepository,
       super(const ProjectRegistrationSubmitState()) {
    on<ProjectRegistrationFormInitialized>(_onFormInitialized);
    on<ProjectRegistrationProjectNameChanged>(_onProjectNameChanged);
    on<ProjectRegistrationFieldChanged>(_onFieldChanged);
    on<ProjectRegistrationPeriodChanged>(_onPeriodChanged);
    on<ProjectRegistrationKeywordChanged>(_onKeywordChanged);
    on<ProjectRegistrationDescriptionChanged>(_onDescriptionChanged);
    on<ProjectRegistrationOutcomeChanged>(_onOutcomeChanged);
    on<ProjectRegistrationPartnerStudentSelected>(_onPartnerStudentSelected);
    on<ProjectRegistrationPartnerStudentRemoved>(_onPartnerStudentRemoved);
    on<ProjectRegistrationSaved>(_onSaved);
  }

  final ProjectRepository _projectRepository;

  void _onFormInitialized(
    ProjectRegistrationFormInitialized event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    final existing = event.existingProject;

    if (existing != null) {
      // Edit mode: pre-fill từ dữ liệu đồ án hiện tại
      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.inProgress,
          isEditMode: true,
          academicYearId: event.academicYearId,
          projectName: existing.projectName,
          field: existing.field,
          period: existing.period,
          keyword: existing.keyword,
          description: existing.description,
          outcome: existing.outcome,
          partnerStudent: null,
          submittedProject: null,
          errorMessage: null,
        ),
      );
    } else {
      // Create mode: form trống
      emit(
        ProjectRegistrationSubmitState(
          status: ProjectRegistrationSubmitStatus.inProgress,
          isEditMode: false,
          academicYearId: event.academicYearId,
        ),
      );
    }
  }

  void _onProjectNameChanged(
    ProjectRegistrationProjectNameChanged event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        projectName: event.value,
        errorMessage: null,
      ),
    );
  }

  void _onFieldChanged(
    ProjectRegistrationFieldChanged event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        field: event.value,
        errorMessage: null,
      ),
    );
  }

  void _onPeriodChanged(
    ProjectRegistrationPeriodChanged event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        period: event.value,
        errorMessage: null,
      ),
    );
  }

  void _onKeywordChanged(
    ProjectRegistrationKeywordChanged event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        keyword: event.value,
        errorMessage: null,
      ),
    );
  }

  void _onDescriptionChanged(
    ProjectRegistrationDescriptionChanged event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        description: event.value,
        errorMessage: null,
      ),
    );
  }

  void _onOutcomeChanged(
    ProjectRegistrationOutcomeChanged event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        outcome: event.value,
        errorMessage: null,
      ),
    );
  }

  void _onPartnerStudentSelected(
    ProjectRegistrationPartnerStudentSelected event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        partnerStudent: event.partner,
        errorMessage: null,
      ),
    );
  }

  void _onPartnerStudentRemoved(
    ProjectRegistrationPartnerStudentRemoved event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.inProgress,
        partnerStudent: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSaved(
    ProjectRegistrationSaved event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: ProjectRegistrationSubmitStatus.submitting));

    try {
      final request = _buildRequest(state);

      // Chọn đúng endpoint theo mode
      final project = state.isEditMode
          ? await _projectRepository.updateProject(request: request)
          : await _projectRepository.registerProject(request: request);

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.success,
          submittedProject: project,
          errorMessage: null,
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.failure,
          errorMessage: readDioErrorMessage(
            e,
            fallback: state.isEditMode
                ? 'Không thể cập nhật đồ án. Vui lòng thử lại.'
                : 'Không thể đăng ký đồ án. Vui lòng thử lại.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.failure,
          errorMessage: 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
        ),
      );
    }
  }

  /// Xây dựng request từ form state.
  /// `members` chỉ chứa thành viên KHÔNG phải leader (người đăng nhập).
  /// Mỗi phần tử có dạng {'studentId': 'B23DCKH001'}.
  ProjectRegistrationRequest _buildRequest(
    ProjectRegistrationSubmitState state,
  ) {
    final members = <Map<String, dynamic>>[];

    if (state.partnerStudent != null) {
      members.add({'studentId': state.partnerStudent!.studentId});
    }

    return ProjectRegistrationRequest(
      academicYearId: state.academicYearId,
      projectName: state.projectName.trim(),
      field: state.field.trim(),
      period: state.period.trim(),
      keyword: state.keyword.trim(),
      description: state.description.trim(),
      outcome: state.outcome.trim(),
      members: members,
    );
  }
}
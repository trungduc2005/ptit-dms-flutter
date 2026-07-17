import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';

import 'project_registration_submit_event.dart';
import 'project_registration_submit_state.dart';

export 'project_registration_submit_event.dart';
export 'project_registration_submit_state.dart';

class ProjectRegistrationSubmitBloc
    extends
        Bloc<ProjectRegistrationSubmitEvent, ProjectRegistrationSubmitState> {
  ProjectRegistrationSubmitBloc({required ProjectRepository projectRepository})
    : _projectRepository = projectRepository,
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
    on<ProjectRegistrationSubmitted>(_onSubmitted);
    on<ProjectRegistrationUpdated>(_onUpdated);
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

  Future<void> _onSubmitted(
    ProjectRegistrationSubmitted event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) async {
    await _submitRequest(
      emit,
      request: event.request,
      action: () => _projectRepository.registerProject(request: event.request),
      successMessage: 'Đăng ký đồ án thành công.',
      failureMessage: 'Không thể đăng ký đồ án. Vui lòng thử lại.',
    );
  }

  Future<void> _onUpdated(
    ProjectRegistrationUpdated event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) async {
    await _submitRequest(
      emit,
      request: event.request,
      action: () => _projectRepository.updateProject(request: event.request),
      successMessage: 'Cập nhật đăng ký đồ án thành công.',
      failureMessage: 'Không thể cập nhật đồ án. Vui lòng thử lại.',
    );
  }

  Future<void> _onSaved(
    ProjectRegistrationSaved event,
    Emitter<ProjectRegistrationSubmitState> emit,
  ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.failure,
          errorMessage: 'Bạn phải nhập đầy đủ thông tin bắt buộc.',
        ),
      );
      return;
    }

    final request = _buildRequest(state);
    await _submitRequest(
      emit,
      request: request,
      action: () => state.isEditMode
          ? _projectRepository.updateProject(request: request)
          : _projectRepository.registerProject(request: request),
      successMessage: state.isEditMode
          ? 'Cập nhật đăng ký đồ án thành công.'
          : 'Đăng ký đồ án thành công.',
      failureMessage: state.isEditMode
          ? 'Không thể cập nhật đồ án. Vui lòng thử lại.'
          : 'Không thể đăng ký đồ án. Vui lòng thử lại.',
    );
  }

  Future<void> _submitRequest(
    Emitter<ProjectRegistrationSubmitState> emit, {
    required ProjectRegistrationRequest request,
    required Future<Project> Function() action,
    required String successMessage,
    required String failureMessage,
  }) async {
    final validationMessage = _validateRequest(request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.failure,
          submittedProject: null,
          errorMessage: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ProjectRegistrationSubmitStatus.submitting,
        submittedProject: null,
        errorMessage: null,
      ),
    );

    try {
      final project = await action();
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.success,
          submittedProject: project,
          errorMessage: successMessage,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.failure,
          submittedProject: null,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectRegistrationSubmitStatus.failure,
          submittedProject: null,
          errorMessage: failureMessage,
        ),
      );
    }
  }

  String? _validateRequest(ProjectRegistrationRequest request) {
    if (request.academicYearId.trim().isEmpty) {
      return 'Bạn phải chọn năm học.';
    }
    if (request.period.trim().isEmpty) {
      return 'Bạn phải chọn học kỳ.';
    }
    if (request.field.trim().isEmpty) {
      return 'Bạn phải nhập lĩnh vực đề tài.';
    }
    if (request.projectName.trim().isEmpty) {
      return 'Bạn phải nhập tên đề tài.';
    }
    if (request.keyword.trim().isEmpty) {
      return 'Bạn phải nhập từ khóa.';
    }
    if (request.description.trim().isEmpty) {
      return 'Bạn phải nhập mô tả đề tài.';
    }
    if (request.outcome.trim().isEmpty) {
      return 'Bạn phải nhập kết quả dự kiến.';
    }

    final memberIds = request.members
        .map((member) => member['studentId']?.toString().trim() ?? '')
        .toList(growable: false);
    if (memberIds.any((id) => id.isEmpty) ||
        memberIds.toSet().length != memberIds.length) {
      return 'Danh sách thành viên không hợp lệ.';
    }

    return null;
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

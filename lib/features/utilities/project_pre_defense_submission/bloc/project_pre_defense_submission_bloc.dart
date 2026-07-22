import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_pre_defense_submission_repository.dart';

import 'project_pre_defense_submission_event.dart';
import 'project_pre_defense_submission_state.dart';

export 'project_pre_defense_submission_event.dart';
export 'project_pre_defense_submission_state.dart';

class ProjectPreDefenseSubmissionBloc
    extends
        Bloc<
          ProjectPreDefenseSubmissionEvent,
          ProjectPreDefenseSubmissionState
        > {
  ProjectPreDefenseSubmissionBloc({
    required ProjectPreDefenseSubmissionRepository repository,
  }) : _repository = repository,
       super(const ProjectPreDefenseSubmissionState()) {
    on<ProjectPreDefenseSubmissionStarted>(_onStarted);
    on<ProjectPreDefenseSubmissionRefreshed>(_onRefreshed);
    on<ProjectPreDefenseSubmissionUploaded>(_onUploaded);
    on<ProjectPreDefenseSubmissionUploadStateCleared>(_onUploadStateCleared);
  }

  final ProjectPreDefenseSubmissionRepository _repository;

  Future<void> _onStarted(
    ProjectPreDefenseSubmissionStarted event,
    Emitter<ProjectPreDefenseSubmissionState> emit,
  ) async {
    final projectId = event.projectId.trim();
    final academicYearId = event.academicYearId.trim();
    final validationMessage = _validateIdentifiers(
      projectId: projectId,
      academicYearId: academicYearId,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.failure,
          projectId: projectId,
          academicYearId: academicYearId,
          submission: null,
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(emit, projectId: projectId, academicYearId: academicYearId);
  }

  Future<void> _onRefreshed(
    ProjectPreDefenseSubmissionRefreshed event,
    Emitter<ProjectPreDefenseSubmissionState> emit,
  ) async {
    final validationMessage = _validateIdentifiers(
      projectId: state.projectId,
      academicYearId: state.academicYearId,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.failure,
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(
      emit,
      projectId: state.projectId,
      academicYearId: state.academicYearId,
    );
  }

  Future<void> _load(
    Emitter<ProjectPreDefenseSubmissionState> emit, {
    required String projectId,
    required String academicYearId,
  }) async {
    emit(
      state.copyWith(
        loadStatus: ProjectPreDefenseSubmissionLoadStatus.loading,
        projectId: projectId,
        academicYearId: academicYearId,
        loadErrorMessage: null,
      ),
    );

    try {
      final submission = await _repository.getSubmission(
        projectId: projectId,
        academicYearId: academicYearId,
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.success,
          submission: submission,
          loadErrorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.failure,
          loadErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.failure,
          loadErrorMessage: 'Không thể tải thông tin nộp đồ án trước bảo vệ.',
        ),
      );
    }
  }

  Future<void> _onUploaded(
    ProjectPreDefenseSubmissionUploaded event,
    Emitter<ProjectPreDefenseSubmissionState> emit,
  ) async {
    final validationMessage = _validateRequest(event.request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.failure,
          uploadProgress: 0,
          uploadMessage: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        uploadStatus: ProjectPreDefenseSubmissionUploadStatus.uploading,
        projectId: event.request.projectId.trim(),
        academicYearId: event.request.academicYearId.trim(),
        uploadProgress: 0,
        uploadMessage: null,
      ),
    );

    try {
      await _repository.uploadSubmission(
        request: event.request,
        onSendProgress: (sentBytes, totalBytes) {
          if (emit.isDone || isClosed || totalBytes <= 0 || sentBytes < 0) {
            return;
          }

          final progress = (sentBytes / totalBytes).clamp(0.0, 1.0);
          if (progress <= state.uploadProgress) return;

          emit(state.copyWith(uploadProgress: progress));
        },
      );

      if (emit.isDone || isClosed) return;

      final submission = await _repository.getSubmission(
        projectId: event.request.projectId.trim(),
        academicYearId: event.request.academicYearId.trim(),
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPreDefenseSubmissionLoadStatus.success,
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.success,
          submission: submission,
          uploadProgress: 1,
          loadErrorMessage: null,
          uploadMessage: 'Nộp đồ án trước bảo vệ thành công.',
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.failure,
          uploadMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProjectPreDefenseSubmissionUploadStatus.failure,
          uploadMessage: 'Không thể nộp đồ án trước bảo vệ.',
        ),
      );
    }
  }

  String? _validateIdentifiers({
    required String projectId,
    required String academicYearId,
  }) {
    if (projectId.isEmpty) return 'Thiếu mã đồ án.';
    if (academicYearId.isEmpty) return 'Thiếu năm học.';
    return null;
  }

  String? _validateRequest(ProjectPreDefenseSubmissionRequest request) {
    try {
      request.validate();
      return null;
    } on FormatException catch (error) {
      return error.message;
    } catch (_) {
      return 'Thông tin hoặc file nộp đồ án không hợp lệ.';
    }
  }

  void _onUploadStateCleared(
    ProjectPreDefenseSubmissionUploadStateCleared event,
    Emitter<ProjectPreDefenseSubmissionState> emit,
  ) {
    emit(
      state.copyWith(
        uploadStatus: ProjectPreDefenseSubmissionUploadStatus.initial,
        uploadProgress: 0,
        uploadMessage: null,
      ),
    );
  }
}

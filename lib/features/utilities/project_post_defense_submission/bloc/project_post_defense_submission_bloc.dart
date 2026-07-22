import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_post_defense_submission_repository.dart';

import 'project_post_defense_submission_event.dart';
import 'project_post_defense_submission_state.dart';

export 'project_post_defense_submission_event.dart';
export 'project_post_defense_submission_state.dart';

class ProjectPostDefenseSubmissionBloc
    extends
        Bloc<
          ProjectPostDefenseSubmissionEvent,
          ProjectPostDefenseSubmissionState
        > {
  ProjectPostDefenseSubmissionBloc({
    required ProjectPostDefenseSubmissionRepository repository,
  }) : _repository = repository,
       super(const ProjectPostDefenseSubmissionState()) {
    on<ProjectPostDefenseSubmissionStarted>(_onStarted);
    on<ProjectPostDefenseSubmissionRefreshed>(_onRefreshed);
    on<ProjectPostDefenseSubmissionUploaded>(_onUploaded);
    on<ProjectPostDefenseSubmissionUploadStateCleared>(_onUploadStateCleared);
  }

  final ProjectPostDefenseSubmissionRepository _repository;

  Future<void> _onStarted(
    ProjectPostDefenseSubmissionStarted event,
    Emitter<ProjectPostDefenseSubmissionState> emit,
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
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.failure,
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
    ProjectPostDefenseSubmissionRefreshed event,
    Emitter<ProjectPostDefenseSubmissionState> emit,
  ) async {
    final validationMessage = _validateIdentifiers(
      projectId: state.projectId,
      academicYearId: state.academicYearId,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.failure,
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
    Emitter<ProjectPostDefenseSubmissionState> emit, {
    required String projectId,
    required String academicYearId,
  }) async {
    emit(
      state.copyWith(
        loadStatus: ProjectPostDefenseSubmissionLoadStatus.loading,
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
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.success,
          submission: submission,
          loadErrorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.failure,
          loadErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.failure,
          loadErrorMessage: 'Không thể tải thông tin nộp đồ án sau bảo vệ.',
        ),
      );
    }
  }

  Future<void> _onUploaded(
    ProjectPostDefenseSubmissionUploaded event,
    Emitter<ProjectPostDefenseSubmissionState> emit,
  ) async {
    final validationMessage = _validateRequest(event.request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.failure,
          uploadProgress: 0,
          uploadMessage: validationMessage,
        ),
      );
      return;
    }

    final projectId = event.request.projectId.trim();
    final academicYearId = event.request.academicYearId.trim();

    emit(
      state.copyWith(
        uploadStatus: ProjectPostDefenseSubmissionUploadStatus.uploading,
        projectId: projectId,
        academicYearId: academicYearId,
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
        projectId: projectId,
        academicYearId: academicYearId,
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectPostDefenseSubmissionLoadStatus.success,
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.success,
          submission: submission,
          uploadProgress: 1,
          loadErrorMessage: null,
          uploadMessage: 'Nộp đồ án sau bảo vệ thành công.',
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.failure,
          uploadMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProjectPostDefenseSubmissionUploadStatus.failure,
          uploadMessage: 'Không thể nộp đồ án sau bảo vệ.',
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

  String? _validateRequest(ProjectPostDefenseSubmissionRequest request) {
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
    ProjectPostDefenseSubmissionUploadStateCleared event,
    Emitter<ProjectPostDefenseSubmissionState> emit,
  ) {
    emit(
      state.copyWith(
        uploadStatus: ProjectPostDefenseSubmissionUploadStatus.initial,
        uploadProgress: 0,
        uploadMessage: null,
      ),
    );
  }
}

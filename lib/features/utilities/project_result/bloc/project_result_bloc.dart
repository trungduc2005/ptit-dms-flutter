import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_result_repository.dart';

import 'project_result_event.dart';
import 'project_result_state.dart';

export 'project_result_event.dart';
export 'project_result_state.dart';

class ProjectResultBloc extends Bloc<ProjectResultEvent, ProjectResultState> {
  ProjectResultBloc(this._repository) : super(const ProjectResultState()) {
    on<ProjectResultStarted>(_onStarted);
    on<ProjectResultRefreshed>(_onRefreshed);
  }

  final ProjectResultRepository _repository;

  Future<void> _onStarted(
    ProjectResultStarted event,
    Emitter<ProjectResultState> emit,
  ) async {
    await _loadResult(
      projectId: event.projectId,
      emit: emit,
      clearResult: true,
    );
  }

  Future<void> _onRefreshed(
    ProjectResultRefreshed event,
    Emitter<ProjectResultState> emit,
  ) async {
    if (state.projectId.isEmpty) return;

    await _loadResult(
      projectId: state.projectId,
      emit: emit,
      clearResult: false,
    );
  }

  Future<void> _loadResult({
    required String projectId,
    required Emitter<ProjectResultState> emit,
    required bool clearResult,
  }) async {
    emit(
      state.copyWith(
        status: ProjectResultStatus.loading,
        projectId: projectId,
        result: clearResult ? null : state.result,
        errorMessage: null,
      ),
    );

    try {
      final result = await _repository.getProjectResult(projectId: projectId);

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectResultStatus.success,
          projectId: projectId,
          result: result,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectResultStatus.failure,
          projectId: projectId,
          errorMessage: error.message,
        ),
      );
    }
  }
}

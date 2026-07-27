import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_committee_repository.dart';

import 'project_committee_event.dart';
import 'project_committee_state.dart';

export 'project_committee_event.dart';
export 'project_committee_state.dart';

class ProjectCommitteeBloc
    extends Bloc<ProjectCommitteeEvent, ProjectCommitteeState> {
  ProjectCommitteeBloc(this._repository)
    : super(const ProjectCommitteeState()) {
    on<ProjectCommitteeStarted>(_onStarted);
    on<ProjectCommitteeRefreshed>(_onRefreshed);
  }

  final ProjectCommitteeRepository _repository;

  Future<void> _onStarted(
    ProjectCommitteeStarted event,
    Emitter<ProjectCommitteeState> emit,
  ) async {
    await _loadCommittee(
      academicYearId: event.academicYearId,
      emit: emit,
      clearCommittee: true,
    );
  }

  Future<void> _onRefreshed(
    ProjectCommitteeRefreshed event,
    Emitter<ProjectCommitteeState> emit,
  ) async {
    if (state.academicYearId.isEmpty) return;

    await _loadCommittee(
      academicYearId: state.academicYearId,
      emit: emit,
      clearCommittee: false,
    );
  }

  Future<void> _loadCommittee({
    required String academicYearId,
    required Emitter<ProjectCommitteeState> emit,
    required bool clearCommittee,
  }) async {
    emit(
      state.copyWith(
        status: ProjectCommitteeStatus.loading,
        academicYearId: academicYearId,
        committee: clearCommittee ? null : state.committee,
        errorMessage: null,
      ),
    );

    try {
      final committee = await _repository.getMyProjectCommittee(
        academicYearId: academicYearId,
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectCommitteeStatus.success,
          academicYearId: academicYearId,
          committee: committee,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProjectCommitteeStatus.failure,
          academicYearId: academicYearId,
          errorMessage: error.message,
        ),
      );
    }
  }
}

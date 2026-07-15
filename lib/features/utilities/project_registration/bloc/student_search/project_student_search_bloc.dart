import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_search_repository.dart';

import 'project_student_search_event.dart';
import 'project_student_search_state.dart';

export 'project_student_search_event.dart';
export 'project_student_search_state.dart';

const _kSearchDebounce = Duration(milliseconds: 350);
const _kMinQueryLength = 2;

class ProjectStudentSearchBloc
    extends Bloc<ProjectStudentSearchEvent, ProjectStudentSearchState> {
  ProjectStudentSearchBloc({
    required StudentSearchRepository studentSearchRepository,
  }) : _studentSearchRepository = studentSearchRepository,
       super(const ProjectStudentSearchInitial()) {
    on<ProjectStudentSearchQueryChanged>(_onQueryChanged);
    on<ProjectStudentSearchCleared>(_onCleared);
    on<_ProjectStudentSearchExecuted>(_onExecuted);
  }

  final StudentSearchRepository _studentSearchRepository;
  Timer? _debounceTimer;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  void _onQueryChanged(
    ProjectStudentSearchQueryChanged event,
    Emitter<ProjectStudentSearchState> emit,
  ) {
    final query = event.query.trim();
    _debounceTimer?.cancel();

    if (query.length < _kMinQueryLength) {
      emit(const ProjectStudentSearchInitial());
      return;
    }

    emit(ProjectStudentSearchLoading(query));

    _debounceTimer = Timer(_kSearchDebounce, () {
      if (!isClosed) {
        add(_ProjectStudentSearchExecuted(query, event.academicYearId));
      }
    });
  }

  Future<void> _onExecuted(
    _ProjectStudentSearchExecuted event,
    Emitter<ProjectStudentSearchState> emit,
  ) async {
    if (state is! ProjectStudentSearchLoading) return;

    try {
      final results = await _studentSearchRepository
          .searchProjectEligibleStudents(
            query: event.query,
            academicYearId: event.academicYearId,
          );

      if (emit.isDone || isClosed) return;

      if (results.isEmpty) {
        emit(ProjectStudentSearchEmpty(event.query));
      } else {
        emit(ProjectStudentSearchLoaded(query: event.query, results: results));
      }
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        ProjectStudentSearchError(
          query: event.query,
          message: readDioErrorMessage(
            e,
            fallback: 'Không thể tìm kiếm sinh viên.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        ProjectStudentSearchError(
          query: event.query,
          message: 'Đã xảy ra lỗi khi tìm kiếm sinh viên.',
        ),
      );
    }
  }

  void _onCleared(
    ProjectStudentSearchCleared event,
    Emitter<ProjectStudentSearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(const ProjectStudentSearchInitial());
  }
}

/// Internal event dùng sau khi debounce timer fire.
final class _ProjectStudentSearchExecuted extends ProjectStudentSearchEvent {
  const _ProjectStudentSearchExecuted(this.query, this.academicYearId);
  final String query;
  final String academicYearId;

  @override
  List<Object?> get props => [query, academicYearId];
}

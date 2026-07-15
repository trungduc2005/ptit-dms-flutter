import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';

import 'project_registration_context_event.dart';
import 'project_registration_context_state.dart';

export 'project_registration_context_event.dart';
export 'project_registration_context_state.dart';

class ProjectRegistrationContextBloc
    extends
        Bloc<ProjectRegistrationContextEvent, ProjectRegistrationContextState> {
  ProjectRegistrationContextBloc({
    required AcademicYearRepository academicYearRepository,
    required ProjectRepository projectRepository,
  }) : _academicYearRepository = academicYearRepository,
       _projectRepository = projectRepository,
       super(const ProjectRegistrationContextState()) {
    on<ProjectRegistrationContextStarted>(_onStarted);
    on<ProjectRegistrationAcademicYearSelected>(_onAcademicYearSelected);
    on<ProjectRegistrationContextRefreshed>(_onRefreshed);
  }

  final AcademicYearRepository _academicYearRepository;
  final ProjectRepository _projectRepository;

  Future<void> _onStarted(
    ProjectRegistrationContextStarted event,
    Emitter<ProjectRegistrationContextState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.loading,
        studentId: event.studentId.trim(),
        isCheckingProject: true,
        existingProject: null,
        mode: ProjectRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      final academicYears = await _academicYearRepository
          .getProjectAcademicYears();

      if (emit.isDone || isClosed) return;

      final selectedAcademicYearId = _resolveSelectedAcademicYearId(
        academicYears: academicYears,
        preferredId: event.initialAcademicYearId,
        fallbackId: state.selectedAcademicYearId,
      );

      if (selectedAcademicYearId == null) {
        emit(
          state.copyWith(
            status: ProjectRegistrationContextStatus.success,
            academicYears: academicYears,
            selectedAcademicYearId: null,
            isCheckingProject: false,
            existingProject: null,
            mode: ProjectRegistrationMode.create,
            errorMessage: null,
          ),
        );
        return;
      }

      await _loadProjectForAcademicYear(
        emit,
        academicYears: academicYears,
        academicYearId: selectedAcademicYearId,
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: readDioErrorMessage(
            e,
            fallback: 'Không thể tải danh sách năm học.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: 'Không thể tải dữ liệu đăng ký đồ án.',
        ),
      );
    }
  }

  Future<void> _onAcademicYearSelected(
    ProjectRegistrationAcademicYearSelected event,
    Emitter<ProjectRegistrationContextState> emit,
  ) async {
    if (state.academicYears.isEmpty) {
      add(
        ProjectRegistrationContextStarted(
          studentId: state.studentId,
          initialAcademicYearId: event.academicYearId,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.loading,
        selectedAcademicYearId: event.academicYearId,
        isCheckingProject: true,
        existingProject: null,
        mode: ProjectRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      await _loadProjectForAcademicYear(
        emit,
        academicYears: state.academicYears,
        academicYearId: event.academicYearId,
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: readDioErrorMessage(
            e,
            fallback: 'Không thể tải dữ liệu năm học đã chọn.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: 'Không thể tải dữ liệu năm học đã chọn.',
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    ProjectRegistrationContextRefreshed event,
    Emitter<ProjectRegistrationContextState> emit,
  ) async {
    final academicYearId = state.selectedAcademicYearId;

    if (academicYearId == null || academicYearId.isEmpty) {
      add(ProjectRegistrationContextStarted(studentId: state.studentId));
      return;
    }

    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.loading,
        isCheckingProject: true,
        existingProject: null,
        mode: ProjectRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      await _loadProjectForAcademicYear(
        emit,
        academicYears: state.academicYears,
        academicYearId: academicYearId,
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: readDioErrorMessage(
            e,
            fallback: 'Không thể làm mới dữ liệu đăng ký đồ án.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: 'Không thể làm mới dữ liệu đăng ký đồ án.',
        ),
      );
    }
  }

  Future<void> _loadProjectForAcademicYear(
    Emitter<ProjectRegistrationContextState> emit, {
    required List<AcademicYearOption> academicYears,
    required String academicYearId,
  }) async {
    final existingProject = await _projectRepository.checkProject(
      academicYearId: academicYearId,
    );

    if (emit.isDone || isClosed) return;

    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.success,
        academicYears: academicYears,
        selectedAcademicYearId: academicYearId,
        isCheckingProject: false,
        existingProject: existingProject,
        mode: _resolveMode(existingProject),
        errorMessage: null,
      ),
    );
  }

  ProjectRegistrationMode _resolveMode(Project? project) {
    if (project == null) return ProjectRegistrationMode.create;
    if (project.isEditable) return ProjectRegistrationMode.edit;
    return ProjectRegistrationMode.view;
  }

  String? _resolveSelectedAcademicYearId({
    required List<AcademicYearOption> academicYears,
    String? preferredId,
    String? fallbackId,
  }) {
    for (final candidate in [preferredId, fallbackId]) {
      if (candidate == null || candidate.isEmpty) continue;
      if (academicYears.any((y) => y.id == candidate)) return candidate;
    }
    if (academicYears.isEmpty) return null;
    return academicYears.first.id;
  }
}

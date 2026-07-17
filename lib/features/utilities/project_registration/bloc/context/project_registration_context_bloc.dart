import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

import 'project_registration_context_event.dart';
import 'project_registration_context_state.dart';

export 'project_registration_context_event.dart';
export 'project_registration_context_state.dart';

class ProjectRegistrationContextBloc
    extends
        Bloc<ProjectRegistrationContextEvent, ProjectRegistrationContextState> {
  ProjectRegistrationContextBloc({
    required StudentProfileRepository studentProfileRepository,
    required AcademicYearRepository academicYearRepository,
    required ProjectRepository projectRepository,
    required TimelineRepository timelineRepository,
  }) : _studentProfileRepository = studentProfileRepository,
       _academicYearRepository = academicYearRepository,
       _projectRepository = projectRepository,
       _timelineRepository = timelineRepository,
       super(const ProjectRegistrationContextState()) {
    on<ProjectRegistrationContextStarted>(_onStarted);
    on<ProjectRegistrationAcademicYearSelected>(_onAcademicYearSelected);
    on<ProjectRegistrationContextRefreshed>(_onRefreshed);
  }

  final StudentProfileRepository _studentProfileRepository;
  final AcademicYearRepository _academicYearRepository;
  final ProjectRepository _projectRepository;
  final TimelineRepository _timelineRepository;

  Future<void> _onStarted(
    ProjectRegistrationContextStarted event,
    Emitter<ProjectRegistrationContextState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.loading,
        profile: null,
        studentId: '',
        periods: const [],
        guiders: const [],
        registrationTimeline: null,
        isCheckingProject: true,
        existingProject: null,
        mode: ProjectRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      // Load profile first
      final profile = await _studentProfileRepository.getProfile();

      if (emit.isDone || isClosed) return;

      final studentId = profile.studentId.trim();

      // Load academic years
      final academicYears = await _academicYearRepository
          .getProjectAcademicYears();

      if (emit.isDone || isClosed) return;

      final periods = await _projectRepository.getProjectPeriods();

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
            profile: profile,
            studentId: studentId,
            academicYears: academicYears,
            selectedAcademicYearId: null,
            periods: periods,
            guiders: const [],
            registrationTimeline: null,
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
        profile: profile,
        academicYears: academicYears,
        periods: periods,
        academicYearId: selectedAcademicYearId,
      );
    } on AppException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
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
    if (state.academicYears.isEmpty || state.profile == null) {
      add(
        ProjectRegistrationContextStarted(
          initialAcademicYearId: event.academicYearId,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.loading,
        selectedAcademicYearId: event.academicYearId,
        guiders: const [],
        registrationTimeline: null,
        isCheckingProject: true,
        existingProject: null,
        mode: ProjectRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      await _loadProjectForAcademicYear(
        emit,
        profile: state.profile!,
        academicYears: state.academicYears,
        periods: state.periods,
        academicYearId: event.academicYearId,
      );
    } on AppException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
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

    if (academicYearId == null ||
        academicYearId.isEmpty ||
        state.profile == null) {
      add(const ProjectRegistrationContextStarted());
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
        profile: state.profile!,
        academicYears: state.academicYears,
        periods: state.periods,
        academicYearId: academicYearId,
      );
    } on AppException catch (e) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          status: ProjectRegistrationContextStatus.failure,
          isCheckingProject: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
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
    required StudentProfile profile,
    required List<AcademicYearOption> academicYears,
    required List<ProjectPeriodOption> periods,
    required String academicYearId,
  }) async {
    final studentId = profile.studentId.trim();
    final results = await Future.wait<Object?>([
      _projectRepository.checkProject(
        academicYearId: academicYearId,
        studentId: studentId,
      ),
      _projectRepository.getProjectGuiders(academicYearId: academicYearId),
      _timelineRepository.getProjectTimelines(academicYearId: academicYearId),
    ]);
    final existingProject = results[0] as Project?;
    final guiders = results[1] as List<ProjectGuiderOption>;
    final timelines = results[2] as List<Timeline>;
    final registrationTimeline = _findRegistrationTimeline(timelines);

    if (emit.isDone || isClosed) return;

    emit(
      state.copyWith(
        status: ProjectRegistrationContextStatus.success,
        profile: profile,
        studentId: studentId,
        academicYears: academicYears,
        selectedAcademicYearId: academicYearId,
        periods: periods,
        guiders: guiders,
        registrationTimeline: registrationTimeline,
        isCheckingProject: false,
        existingProject: existingProject,
        mode: _resolveMode(existingProject, studentId: studentId),
        errorMessage: null,
      ),
    );
  }

  Timeline? _findRegistrationTimeline(List<Timeline> timelines) {
    for (final timeline in timelines) {
      if (timeline.type == 'projectRegistration') return timeline;
    }
    return null;
  }

  ProjectRegistrationMode _resolveMode(
    Project? project, {
    required String studentId,
  }) {
    if (project == null) return ProjectRegistrationMode.create;

    final isLeader =
        studentId.isNotEmpty &&
        project.members.any(
          (member) => member.isLeader && member.studentId.trim() == studentId,
        );

    if (isLeader && project.isEditable) {
      return ProjectRegistrationMode.edit;
    }

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

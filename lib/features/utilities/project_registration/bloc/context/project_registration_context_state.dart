import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';

enum ProjectRegistrationContextStatus { initial, loading, success, failure }

/// Chế độ hiển thị form đăng ký đồ án.
enum ProjectRegistrationMode { create, edit, view }

const _unset = Object();

final class ProjectRegistrationContextState extends Equatable {
  const ProjectRegistrationContextState({
    this.status = ProjectRegistrationContextStatus.initial,
    this.profile,
    this.studentId = '',
    this.academicYears = const [],
    this.selectedAcademicYearId,
    this.periods = const [],
    this.guiders = const [],
    this.registrationTimeline,
    this.isCheckingProject = false,
    this.existingProject,
    this.mode = ProjectRegistrationMode.create,
    this.errorMessage,
  });

  final ProjectRegistrationContextStatus status;
  final StudentProfile? profile;
  final String studentId;
  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final List<ProjectPeriodOption> periods;
  final List<ProjectGuiderOption> guiders;
  final Timeline? registrationTimeline;
  final bool isCheckingProject;
  final Project? existingProject;
  final ProjectRegistrationMode mode;
  final String? errorMessage;

  int get minMember => registrationTimeline?.minMember ?? 1;

  int get maxMember => registrationTimeline?.maxMember ?? minMember;

  bool get hasExistingProject => existingProject != null;

  Project? get currentRegistration => existingProject;

  bool get isViewOnly => mode == ProjectRegistrationMode.view;

  bool get canCreateRegistration =>
      mode == ProjectRegistrationMode.create && !hasExistingProject;

  bool get canEditRegistration =>
      mode == ProjectRegistrationMode.edit && hasExistingProject;

  ProjectRegistrationContextState copyWith({
    ProjectRegistrationContextStatus? status,
    Object? profile = _unset,
    String? studentId,
    List<AcademicYearOption>? academicYears,
    Object? selectedAcademicYearId = _unset,
    List<ProjectPeriodOption>? periods,
    List<ProjectGuiderOption>? guiders,
    Object? registrationTimeline = _unset,
    bool? isCheckingProject,
    Object? existingProject = _unset,
    ProjectRegistrationMode? mode,
    Object? errorMessage = _unset,
  }) {
    return ProjectRegistrationContextState(
      status: status ?? this.status,
      profile: identical(profile, _unset)
          ? this.profile
          : profile as StudentProfile?,
      studentId: studentId ?? this.studentId,
      academicYears: academicYears ?? this.academicYears,
      selectedAcademicYearId: identical(selectedAcademicYearId, _unset)
          ? this.selectedAcademicYearId
          : selectedAcademicYearId as String?,
      periods: periods ?? this.periods,
      guiders: guiders ?? this.guiders,
      registrationTimeline: identical(registrationTimeline, _unset)
          ? this.registrationTimeline
          : registrationTimeline as Timeline?,
      isCheckingProject: isCheckingProject ?? this.isCheckingProject,
      existingProject: identical(existingProject, _unset)
          ? this.existingProject
          : existingProject as Project?,
      mode: mode ?? this.mode,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    studentId,
    academicYears,
    selectedAcademicYearId,
    periods,
    guiders,
    registrationTimeline,
    isCheckingProject,
    existingProject,
    mode,
    errorMessage,
  ];
}

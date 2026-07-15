import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';

enum ProjectRegistrationContextStatus { initial, loading, success, failure }

/// Chế độ hiển thị form đăng ký đồ án.
enum ProjectRegistrationMode { create, edit, view }

const _unset = Object();

final class ProjectRegistrationContextState extends Equatable {
  const ProjectRegistrationContextState({
    this.status = ProjectRegistrationContextStatus.initial,
    this.studentId = '',
    this.academicYears = const [],
    this.selectedAcademicYearId,
    this.isCheckingProject = false,
    this.existingProject,
    this.mode = ProjectRegistrationMode.create,
    this.errorMessage,
  });

  final ProjectRegistrationContextStatus status;
  final String studentId;
  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final bool isCheckingProject;
  final Project? existingProject;
  final ProjectRegistrationMode mode;
  final String? errorMessage;

  bool get hasExistingProject => existingProject != null;

  Project? get currentRegistration => existingProject;

  bool get isViewOnly => mode == ProjectRegistrationMode.view;

  bool get canCreateRegistration =>
      mode == ProjectRegistrationMode.create && !hasExistingProject;

  bool get canEditRegistration =>
      mode == ProjectRegistrationMode.edit && hasExistingProject;

  ProjectRegistrationContextState copyWith({
    ProjectRegistrationContextStatus? status,
    String? studentId,
    List<AcademicYearOption>? academicYears,
    Object? selectedAcademicYearId = _unset,
    bool? isCheckingProject,
    Object? existingProject = _unset,
    ProjectRegistrationMode? mode,
    Object? errorMessage = _unset,
  }) {
    return ProjectRegistrationContextState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      academicYears: academicYears ?? this.academicYears,
      selectedAcademicYearId: identical(selectedAcademicYearId, _unset)
          ? this.selectedAcademicYearId
          : selectedAcademicYearId as String?,
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
    studentId,
    academicYears,
    selectedAcademicYearId,
    isCheckingProject,
    existingProject,
    mode,
    errorMessage,
  ];
}

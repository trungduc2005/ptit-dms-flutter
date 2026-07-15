import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

enum ProjectRegistrationSubmitStatus {
  initial,
  inProgress,
  submitting,
  success,
  failure,
}

const _unset = Object();

final class ProjectRegistrationSubmitState extends Equatable {
  const ProjectRegistrationSubmitState({
    this.status = ProjectRegistrationSubmitStatus.initial,
    this.isEditMode = false,
    this.academicYearId = '',
    this.projectName = '',
    this.field = '',
    this.period = '',
    this.keyword = '',
    this.description = '',
    this.outcome = '',
    this.partnerStudent,
    this.submittedProject,
    this.errorMessage,
  });

  final ProjectRegistrationSubmitStatus status;

  /// True khi đang ở chế độ cập nhật (status = project_needs_revision).
  final bool isEditMode;

  final String academicYearId;
  final String projectName;
  final String field;
  final String period;
  final String keyword;
  final String description;
  final String outcome;

  /// Sinh viên ghép nhóm (tuỳ chọn, tối đa 1 người).
  final StudentSearchResult? partnerStudent;

  /// Đồ án vừa được tạo / cập nhật thành công.
  final Project? submittedProject;

  final String? errorMessage;

  bool get isValid =>
      academicYearId.isNotEmpty &&
      projectName.trim().isNotEmpty &&
      field.trim().isNotEmpty &&
      period.trim().isNotEmpty &&
      keyword.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      outcome.trim().isNotEmpty;

  bool get isSubmitting =>
      status == ProjectRegistrationSubmitStatus.submitting;

  bool get isBusy =>
      status == ProjectRegistrationSubmitStatus.inProgress ||
      status == ProjectRegistrationSubmitStatus.submitting;

  String? get message => errorMessage;

  ProjectRegistrationSubmitState copyWith({
    ProjectRegistrationSubmitStatus? status,
    bool? isEditMode,
    String? academicYearId,
    String? projectName,
    String? field,
    String? period,
    String? keyword,
    String? description,
    String? outcome,
    Object? partnerStudent = _unset,
    Object? submittedProject = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProjectRegistrationSubmitState(
      status: status ?? this.status,
      isEditMode: isEditMode ?? this.isEditMode,
      academicYearId: academicYearId ?? this.academicYearId,
      projectName: projectName ?? this.projectName,
      field: field ?? this.field,
      period: period ?? this.period,
      keyword: keyword ?? this.keyword,
      description: description ?? this.description,
      outcome: outcome ?? this.outcome,
      partnerStudent: identical(partnerStudent, _unset)
          ? this.partnerStudent
          : partnerStudent as StudentSearchResult?,
      submittedProject: identical(submittedProject, _unset)
          ? this.submittedProject
          : submittedProject as Project?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isEditMode,
    academicYearId,
    projectName,
    field,
    period,
    keyword,
    description,
    outcome,
    partnerStudent,
    submittedProject,
    errorMessage,
  ];
}
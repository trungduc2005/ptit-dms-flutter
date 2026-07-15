import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

sealed class ProjectRegistrationSubmitEvent extends Equatable {
  const ProjectRegistrationSubmitEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo form với dữ liệu ban đầu.
final class ProjectRegistrationFormInitialized
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationFormInitialized({
    required this.academicYearId,
    this.existingProject,
  });

  final String academicYearId;
  final Project? existingProject;

  @override
  List<Object?> get props => [academicYearId, existingProject];
}

final class ProjectRegistrationProjectNameChanged
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationProjectNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProjectRegistrationFieldChanged
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationFieldChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProjectRegistrationPeriodChanged
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationPeriodChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProjectRegistrationKeywordChanged
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationKeywordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProjectRegistrationDescriptionChanged
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationDescriptionChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ProjectRegistrationOutcomeChanged
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationOutcomeChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

/// Chọn sinh viên ghép nhóm.
final class ProjectRegistrationPartnerStudentSelected
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationPartnerStudentSelected(this.partner);
  final StudentSearchResult partner;

  @override
  List<Object?> get props => [partner];
}

/// Bỏ chọn sinh viên ghép nhóm.
final class ProjectRegistrationPartnerStudentRemoved
    extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationPartnerStudentRemoved();
}

/// Gửi đăng ký mới.
final class ProjectRegistrationSubmitted extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationSubmitted({required this.request});
  
  final ProjectRegistrationRequest request;
  
  @override
  List<Object?> get props => [request];
}

/// Cập nhật đăng ký hiện tại.
final class ProjectRegistrationUpdated extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationUpdated({required this.request});
  
  final ProjectRegistrationRequest request;
  
  @override
  List<Object?> get props => [request];
}

/// Bấm nút đăng ký / cập nhật (legacy - dùng field changes).
final class ProjectRegistrationSaved extends ProjectRegistrationSubmitEvent {
  const ProjectRegistrationSaved();
}

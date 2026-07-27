import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_committee.dart';

enum ProjectCommitteeStatus { initial, loading, success, failure }

const _unset = Object();

final class ProjectCommitteeState extends Equatable {
  const ProjectCommitteeState({
    this.status = ProjectCommitteeStatus.initial,
    this.academicYearId = '',
    this.committee,
    this.errorMessage,
  });

  final ProjectCommitteeStatus status;
  final String academicYearId;
  final ProjectCommittee? committee;
  final String? errorMessage;

  bool get hasCommittee => committee != null;

  ProjectCommitteeState copyWith({
    ProjectCommitteeStatus? status,
    String? academicYearId,
    Object? committee = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProjectCommitteeState(
      status: status ?? this.status,
      academicYearId: academicYearId ?? this.academicYearId,
      committee: identical(committee, _unset)
          ? this.committee
          : committee as ProjectCommittee?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, academicYearId, committee, errorMessage];
}

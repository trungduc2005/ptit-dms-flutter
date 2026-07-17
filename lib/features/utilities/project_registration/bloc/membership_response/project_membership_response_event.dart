import 'package:equatable/equatable.dart';

sealed class ProjectMembershipResponseEvent extends Equatable {
  const ProjectMembershipResponseEvent();

  @override
  List<Object?> get props => [];
}

final class ProjectMembershipApproved extends ProjectMembershipResponseEvent {
  const ProjectMembershipApproved({
    required this.projectId,
    required this.studentRef,
  });

  final String projectId;
  final String studentRef;

  @override
  List<Object?> get props => [projectId, studentRef];
}

final class ProjectMembershipRejected extends ProjectMembershipResponseEvent {
  const ProjectMembershipRejected({
    required this.projectId,
    required this.studentRef,
    this.reason,
  });

  final String projectId;
  final String studentRef;
  final String? reason;

  @override
  List<Object?> get props => [projectId, studentRef, reason];
}

import 'package:equatable/equatable.dart';

enum ProjectMembershipResponseStatus { initial, submitting, success, failure }

enum ProjectMembershipResponseAction { approve, reject }

final class ProjectMembershipResponseState extends Equatable {
  const ProjectMembershipResponseState({
    this.status = ProjectMembershipResponseStatus.initial,
    this.action,
    this.message,
  });

  final ProjectMembershipResponseStatus status;
  final ProjectMembershipResponseAction? action;
  final String? message;

  bool get isSubmitting => status == ProjectMembershipResponseStatus.submitting;

  @override
  List<Object?> get props => [status, action, message];
}

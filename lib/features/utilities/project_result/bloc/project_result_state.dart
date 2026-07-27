import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_result.dart';

enum ProjectResultStatus { initial, loading, success, failure }

const _unset = Object();

final class ProjectResultState extends Equatable {
  const ProjectResultState({
    this.status = ProjectResultStatus.initial,
    this.projectId = '',
    this.result,
    this.errorMessage,
  });

  final ProjectResultStatus status;
  final String projectId;
  final ProjectResult? result;
  final String? errorMessage;

  bool get hasResult => result != null;
  bool get isPublished => result?.isPublished ?? false;

  ProjectResultState copyWith({
    ProjectResultStatus? status,
    String? projectId,
    Object? result = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProjectResultState(
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      result: identical(result, _unset)
          ? this.result
          : result as ProjectResult?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, projectId, result, errorMessage];
}

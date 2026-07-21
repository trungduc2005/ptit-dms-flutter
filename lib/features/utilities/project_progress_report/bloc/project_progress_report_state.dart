import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';

enum ProjectProgressReportLoadStatus { initial, loading, success, failure }

enum ProjectProgressReportActionStatus { initial, loading, success, failure }

enum ProjectProgressReportAction { create, update }

const _unset = Object();

final class ProjectProgressReportState extends Equatable {
  const ProjectProgressReportState({
    this.loadStatus = ProjectProgressReportLoadStatus.initial,
    this.actionStatus = ProjectProgressReportActionStatus.initial,
    this.action,
    this.projectObjectId = '',
    this.projectId = '',
    this.academicYearId = '',
    this.reports = const [],
    this.replies = const [],
    this.savedReport,
    this.loadErrorMessage,
    this.actionMessage,
  });

  final ProjectProgressReportLoadStatus loadStatus;
  final ProjectProgressReportActionStatus actionStatus;
  final ProjectProgressReportAction? action;

  /// MongoDB `_id` của đồ án.
  final String projectObjectId;

  /// Mã nghiệp vụ của đồ án.
  final String projectId;

  final String academicYearId;
  final List<ProjectProgressReport> reports;
  final List<ProjectReportReply> replies;
  final ProjectProgressReport? savedReport;
  final String? loadErrorMessage;
  final String? actionMessage;

  bool get isLoading => loadStatus == ProjectProgressReportLoadStatus.loading;

  bool get isSubmitting =>
      actionStatus == ProjectProgressReportActionStatus.loading;

  ProjectProgressReportState copyWith({
    ProjectProgressReportLoadStatus? loadStatus,
    ProjectProgressReportActionStatus? actionStatus,
    Object? action = _unset,
    String? projectObjectId,
    String? projectId,
    String? academicYearId,
    List<ProjectProgressReport>? reports,
    List<ProjectReportReply>? replies,
    Object? savedReport = _unset,
    Object? loadErrorMessage = _unset,
    Object? actionMessage = _unset,
  }) {
    return ProjectProgressReportState(
      loadStatus: loadStatus ?? this.loadStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      action: identical(action, _unset)
          ? this.action
          : action as ProjectProgressReportAction?,
      projectObjectId: projectObjectId ?? this.projectObjectId,
      projectId: projectId ?? this.projectId,
      academicYearId: academicYearId ?? this.academicYearId,
      reports: reports ?? this.reports,
      replies: replies ?? this.replies,
      savedReport: identical(savedReport, _unset)
          ? this.savedReport
          : savedReport as ProjectProgressReport?,
      loadErrorMessage: identical(loadErrorMessage, _unset)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      actionMessage: identical(actionMessage, _unset)
          ? this.actionMessage
          : actionMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    actionStatus,
    action,
    projectObjectId,
    projectId,
    academicYearId,
    reports,
    replies,
    savedReport,
    loadErrorMessage,
    actionMessage,
  ];
}

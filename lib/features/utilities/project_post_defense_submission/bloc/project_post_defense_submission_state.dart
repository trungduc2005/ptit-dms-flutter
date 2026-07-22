import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission.dart';

enum ProjectPostDefenseSubmissionLoadStatus {
  initial,
  loading,
  success,
  failure,
}

enum ProjectPostDefenseSubmissionUploadStatus {
  initial,
  uploading,
  success,
  failure,
}

const _unset = Object();

final class ProjectPostDefenseSubmissionState extends Equatable {
  const ProjectPostDefenseSubmissionState({
    this.loadStatus = ProjectPostDefenseSubmissionLoadStatus.initial,
    this.uploadStatus = ProjectPostDefenseSubmissionUploadStatus.initial,
    this.projectId = '',
    this.academicYearId = '',
    this.submission,
    this.uploadProgress = 0,
    this.loadErrorMessage,
    this.uploadMessage,
  });

  final ProjectPostDefenseSubmissionLoadStatus loadStatus;
  final ProjectPostDefenseSubmissionUploadStatus uploadStatus;
  final String projectId;
  final String academicYearId;
  final ProjectPostDefenseSubmission? submission;

  /// Tiến độ upload đã chuẩn hóa trong khoảng từ 0 đến 1.
  final double uploadProgress;

  final String? loadErrorMessage;
  final String? uploadMessage;

  bool get isLoading =>
      loadStatus == ProjectPostDefenseSubmissionLoadStatus.loading;

  bool get isUploading =>
      uploadStatus == ProjectPostDefenseSubmissionUploadStatus.uploading;

  bool get isBusy => isLoading || isUploading;

  bool get hasSubmitted => submission?.hasSubmitted ?? false;

  bool get canUpload => submission?.canResubmit ?? true;

  bool get isFullyApproved => submission?.isFullyApproved ?? false;

  ProjectPostDefenseSubmissionState copyWith({
    ProjectPostDefenseSubmissionLoadStatus? loadStatus,
    ProjectPostDefenseSubmissionUploadStatus? uploadStatus,
    String? projectId,
    String? academicYearId,
    Object? submission = _unset,
    double? uploadProgress,
    Object? loadErrorMessage = _unset,
    Object? uploadMessage = _unset,
  }) {
    return ProjectPostDefenseSubmissionState(
      loadStatus: loadStatus ?? this.loadStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      projectId: projectId ?? this.projectId,
      academicYearId: academicYearId ?? this.academicYearId,
      submission: identical(submission, _unset)
          ? this.submission
          : submission as ProjectPostDefenseSubmission?,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      loadErrorMessage: identical(loadErrorMessage, _unset)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      uploadMessage: identical(uploadMessage, _unset)
          ? this.uploadMessage
          : uploadMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    uploadStatus,
    projectId,
    academicYearId,
    submission,
    uploadProgress,
    loadErrorMessage,
    uploadMessage,
  ];
}

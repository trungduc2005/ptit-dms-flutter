import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';

enum ProjectPreDefenseSubmissionLoadStatus {
  initial,
  loading,
  success,
  failure,
}

enum ProjectPreDefenseSubmissionUploadStatus {
  initial,
  uploading,
  success,
  failure,
}

const _unset = Object();

final class ProjectPreDefenseSubmissionState extends Equatable {
  const ProjectPreDefenseSubmissionState({
    this.loadStatus = ProjectPreDefenseSubmissionLoadStatus.initial,
    this.uploadStatus = ProjectPreDefenseSubmissionUploadStatus.initial,
    this.projectId = '',
    this.academicYearId = '',
    this.submission,
    this.uploadProgress = 0,
    this.loadErrorMessage,
    this.uploadMessage,
  });

  final ProjectPreDefenseSubmissionLoadStatus loadStatus;
  final ProjectPreDefenseSubmissionUploadStatus uploadStatus;
  final String projectId;
  final String academicYearId;
  final ProjectPreDefenseSubmission? submission;

  /// Tiến độ upload đã chuẩn hóa trong khoảng từ 0 đến 1.
  final double uploadProgress;

  final String? loadErrorMessage;
  final String? uploadMessage;

  bool get isLoading =>
      loadStatus == ProjectPreDefenseSubmissionLoadStatus.loading;

  bool get isUploading =>
      uploadStatus == ProjectPreDefenseSubmissionUploadStatus.uploading;

  bool get isBusy => isLoading || isUploading;

  bool get hasSubmitted => submission?.hasSubmitted ?? false;

  bool get canUpload => submission?.canResubmit ?? true;

  ProjectPreDefenseSubmissionState copyWith({
    ProjectPreDefenseSubmissionLoadStatus? loadStatus,
    ProjectPreDefenseSubmissionUploadStatus? uploadStatus,
    String? projectId,
    String? academicYearId,
    Object? submission = _unset,
    double? uploadProgress,
    Object? loadErrorMessage = _unset,
    Object? uploadMessage = _unset,
  }) {
    return ProjectPreDefenseSubmissionState(
      loadStatus: loadStatus ?? this.loadStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      projectId: projectId ?? this.projectId,
      academicYearId: academicYearId ?? this.academicYearId,
      submission: identical(submission, _unset)
          ? this.submission
          : submission as ProjectPreDefenseSubmission?,
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

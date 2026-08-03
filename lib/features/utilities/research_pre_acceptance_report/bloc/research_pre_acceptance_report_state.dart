import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';

enum ResearchPreAcceptanceReportLoadStatus {
  initial,
  loading,
  success,
  failure,
}

enum ResearchPreAcceptanceReportUploadStatus {
  initial,
  uploading,
  success,
  failure,
}

const _unset = Object();

final class ResearchPreAcceptanceReportState extends Equatable {
  const ResearchPreAcceptanceReportState({
    this.loadStatus = ResearchPreAcceptanceReportLoadStatus.initial,
    this.uploadStatus = ResearchPreAcceptanceReportUploadStatus.initial,
    this.researchId = '',
    this.yearId = '',
    this.reports = const [],
    double uploadProgress = 0,
    this.loadErrorMessage,
    this.uploadMessage,
  }) : uploadProgress = uploadProgress < 0
           ? 0
           : uploadProgress > 1
           ? 1
           : uploadProgress;

  final ResearchPreAcceptanceReportLoadStatus loadStatus;
  final ResearchPreAcceptanceReportUploadStatus uploadStatus;
  final String researchId;
  final String yearId;
  final List<ResearchPreAcceptanceReport> reports;
  final double uploadProgress;
  final String? loadErrorMessage;
  final String? uploadMessage;

  bool get isLoading =>
      loadStatus == ResearchPreAcceptanceReportLoadStatus.loading;

  bool get isUploading =>
      uploadStatus == ResearchPreAcceptanceReportUploadStatus.uploading;

  bool get isBusy => isLoading || isUploading;

  bool get isEmpty =>
      loadStatus == ResearchPreAcceptanceReportLoadStatus.success &&
      reports.isEmpty;

  ResearchPreAcceptanceReportState copyWith({
    ResearchPreAcceptanceReportLoadStatus? loadStatus,
    ResearchPreAcceptanceReportUploadStatus? uploadStatus,
    String? researchId,
    String? yearId,
    List<ResearchPreAcceptanceReport>? reports,
    double? uploadProgress,
    Object? loadErrorMessage = _unset,
    Object? uploadMessage = _unset,
  }) {
    return ResearchPreAcceptanceReportState(
      loadStatus: loadStatus ?? this.loadStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      researchId: researchId ?? this.researchId,
      yearId: yearId ?? this.yearId,
      reports: reports ?? this.reports,
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
    researchId,
    yearId,
    reports,
    uploadProgress,
    loadErrorMessage,
    uploadMessage,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';

enum ResearchPostAcceptanceReportLoadStatus {
  initial,
  loading,
  success,
  failure,
}

enum ResearchPostAcceptanceReportUploadStatus {
  initial,
  uploading,
  success,
  failure,
}

enum ResearchPostAcceptanceReportDownloadStatus {
  initial,
  downloading,
  success,
  failure,
}

const _unset = Object();

final class ResearchPostAcceptanceReportState extends Equatable {
  const ResearchPostAcceptanceReportState({
    this.loadStatus = ResearchPostAcceptanceReportLoadStatus.initial,
    this.uploadStatus = ResearchPostAcceptanceReportUploadStatus.initial,
    this.downloadStatus = ResearchPostAcceptanceReportDownloadStatus.initial,
    this.researchId = '',
    this.yearId = '',
    this.reports = const [],
    double uploadProgress = 0,
    this.downloadingFileKey,
    this.downloadedFile,
    this.loadErrorMessage,
    this.uploadMessage,
    this.downloadMessage,
  }) : uploadProgress = uploadProgress < 0
           ? 0
           : uploadProgress > 1
           ? 1
           : uploadProgress;

  final ResearchPostAcceptanceReportLoadStatus loadStatus;
  final ResearchPostAcceptanceReportUploadStatus uploadStatus;
  final ResearchPostAcceptanceReportDownloadStatus downloadStatus;
  final String researchId;
  final String yearId;
  final List<ResearchPostAcceptanceReport> reports;
  final double uploadProgress;
  final String? downloadingFileKey;
  final ResearchPostAcceptanceReportDownload? downloadedFile;
  final String? loadErrorMessage;
  final String? uploadMessage;
  final String? downloadMessage;

  bool get isLoading =>
      loadStatus == ResearchPostAcceptanceReportLoadStatus.loading;

  bool get isUploading =>
      uploadStatus == ResearchPostAcceptanceReportUploadStatus.uploading;

  bool get isDownloading =>
      downloadStatus == ResearchPostAcceptanceReportDownloadStatus.downloading;

  bool get isBusy => isLoading || isUploading || isDownloading;

  bool get isEmpty =>
      loadStatus == ResearchPostAcceptanceReportLoadStatus.success &&
      reports.isEmpty;

  ResearchPostAcceptanceReportState copyWith({
    ResearchPostAcceptanceReportLoadStatus? loadStatus,
    ResearchPostAcceptanceReportUploadStatus? uploadStatus,
    ResearchPostAcceptanceReportDownloadStatus? downloadStatus,
    String? researchId,
    String? yearId,
    List<ResearchPostAcceptanceReport>? reports,
    double? uploadProgress,
    Object? downloadingFileKey = _unset,
    Object? downloadedFile = _unset,
    Object? loadErrorMessage = _unset,
    Object? uploadMessage = _unset,
    Object? downloadMessage = _unset,
  }) {
    return ResearchPostAcceptanceReportState(
      loadStatus: loadStatus ?? this.loadStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      researchId: researchId ?? this.researchId,
      yearId: yearId ?? this.yearId,
      reports: reports ?? this.reports,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      downloadingFileKey: identical(downloadingFileKey, _unset)
          ? this.downloadingFileKey
          : downloadingFileKey as String?,
      downloadedFile: identical(downloadedFile, _unset)
          ? this.downloadedFile
          : downloadedFile as ResearchPostAcceptanceReportDownload?,
      loadErrorMessage: identical(loadErrorMessage, _unset)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      uploadMessage: identical(uploadMessage, _unset)
          ? this.uploadMessage
          : uploadMessage as String?,
      downloadMessage: identical(downloadMessage, _unset)
          ? this.downloadMessage
          : downloadMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    uploadStatus,
    downloadStatus,
    researchId,
    yearId,
    reports,
    uploadProgress,
    downloadingFileKey,
    downloadedFile,
    loadErrorMessage,
    uploadMessage,
    downloadMessage,
  ];
}

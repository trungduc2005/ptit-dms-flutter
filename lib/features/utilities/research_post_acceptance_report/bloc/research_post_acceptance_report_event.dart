import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';

sealed class ResearchPostAcceptanceReportEvent extends Equatable {
  const ResearchPostAcceptanceReportEvent();

  @override
  List<Object?> get props => const [];
}

final class ResearchPostAcceptanceReportStarted
    extends ResearchPostAcceptanceReportEvent {
  const ResearchPostAcceptanceReportStarted({
    required this.researchId,
    required this.yearId,
  });

  final String researchId;
  final String yearId;

  @override
  List<Object?> get props => [researchId, yearId];
}

final class ResearchPostAcceptanceReportRefreshed
    extends ResearchPostAcceptanceReportEvent {
  const ResearchPostAcceptanceReportRefreshed();
}

final class ResearchPostAcceptanceReportUploaded
    extends ResearchPostAcceptanceReportEvent {
  const ResearchPostAcceptanceReportUploaded({required this.request});

  final ResearchPostAcceptanceReportRequest request;

  @override
  List<Object?> get props => [request];
}

final class ResearchPostAcceptanceReportUploadStateCleared
    extends ResearchPostAcceptanceReportEvent {
  const ResearchPostAcceptanceReportUploadStateCleared();
}

final class ResearchPostAcceptanceReportFileDownloaded
    extends ResearchPostAcceptanceReportEvent {
  const ResearchPostAcceptanceReportFileDownloaded({
    required this.fileKey,
    this.yearId,
  });

  final String fileKey;
  final String? yearId;

  @override
  List<Object?> get props => [fileKey, yearId];
}

final class ResearchPostAcceptanceReportDownloadStateCleared
    extends ResearchPostAcceptanceReportEvent {
  const ResearchPostAcceptanceReportDownloadStateCleared();
}

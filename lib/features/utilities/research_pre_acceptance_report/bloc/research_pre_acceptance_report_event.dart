import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';

sealed class ResearchPreAcceptanceReportEvent extends Equatable {
  const ResearchPreAcceptanceReportEvent();

  @override
  List<Object?> get props => const [];
}

final class ResearchPreAcceptanceReportStarted
    extends ResearchPreAcceptanceReportEvent {
  const ResearchPreAcceptanceReportStarted({
    required this.researchId,
    required this.yearId,
  });

  final String researchId;
  final String yearId;

  @override
  List<Object?> get props => [researchId, yearId];
}

final class ResearchPreAcceptanceReportRefreshed
    extends ResearchPreAcceptanceReportEvent {
  const ResearchPreAcceptanceReportRefreshed();
}

final class ResearchPreAcceptanceReportUploaded
    extends ResearchPreAcceptanceReportEvent {
  const ResearchPreAcceptanceReportUploaded({required this.request});

  final ResearchPreAcceptanceReportRequest request;

  @override
  List<Object?> get props => [request];
}

final class ResearchPreAcceptanceReportUploadStateCleared
    extends ResearchPreAcceptanceReportEvent {
  const ResearchPreAcceptanceReportUploadStateCleared();
}

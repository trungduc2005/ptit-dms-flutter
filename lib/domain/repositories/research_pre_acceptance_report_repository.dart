import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';

typedef ResearchPreAcceptanceUploadProgressCallback =
    void Function(int sentBytes, int totalBytes);

abstract interface class ResearchPreAcceptanceReportRepository {
  Future<List<ResearchPreAcceptanceReport>> getReports({
    required String researchId,
    required String yearId,
  });

  Future<void> uploadReport({
    required ResearchPreAcceptanceReportRequest request,
    ResearchPreAcceptanceUploadProgressCallback? onSendProgress,
  });
}

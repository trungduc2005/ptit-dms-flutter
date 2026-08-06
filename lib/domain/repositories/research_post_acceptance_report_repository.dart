import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';

typedef ResearchPostAcceptanceUploadProgressCallback =
    void Function(int sentBytes, int totalBytes);

abstract interface class ResearchPostAcceptanceReportRepository {
  Future<List<ResearchPostAcceptanceReport>> getReports({
    required String researchId,
    required String yearId,
  });

  Future<void> uploadReport({
    required ResearchPostAcceptanceReportRequest request,
    ResearchPostAcceptanceUploadProgressCallback? onSendProgress,
  });

  Future<ResearchPostAcceptanceReportDownload> downloadFile({
    required String fileKey,
    required String yearId,
  });
}

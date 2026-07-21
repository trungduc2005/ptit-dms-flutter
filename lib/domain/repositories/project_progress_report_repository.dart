import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';

abstract interface class ProjectProgressReportRepository {
  /// Lấy báo cáo theo MongoDB `_id` của đồ án.
  Future<List<ProjectProgressReport>> getReports({
    required String projectObjectId,
    required String academicYearId,
  });

  /// Lấy toàn bộ phản hồi theo mã nghiệp vụ của đồ án.
  Future<List<ProjectReportReply>> getReplies({
    required String projectId,
    required String academicYearId,
  });

  Future<ProjectProgressReport> createReport({
    required ProjectProgressReportRequest request,
  });

  Future<ProjectProgressReport> updateReport({
    required ProjectProgressReportRequest request,
  });
}

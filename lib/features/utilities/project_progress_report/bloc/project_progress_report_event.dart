import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';

sealed class ProjectProgressReportEvent extends Equatable {
  const ProjectProgressReportEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải danh sách báo cáo và phản hồi của đồ án.
final class ProjectProgressReportStarted extends ProjectProgressReportEvent {
  const ProjectProgressReportStarted({
    required this.projectObjectId,
    required this.projectId,
    required this.academicYearId,
  });

  /// MongoDB `_id` dùng để lấy danh sách báo cáo.
  final String projectObjectId;

  /// Mã nghiệp vụ của đồ án dùng để lấy phản hồi.
  final String projectId;

  final String academicYearId;

  @override
  List<Object?> get props => [projectObjectId, projectId, academicYearId];
}

/// Tải lại dữ liệu bằng thông tin đồ án đang có trong state.
final class ProjectProgressReportRefreshed extends ProjectProgressReportEvent {
  const ProjectProgressReportRefreshed();
}

final class ProjectProgressReportCreated extends ProjectProgressReportEvent {
  const ProjectProgressReportCreated({required this.request});

  final ProjectProgressReportRequest request;

  @override
  List<Object?> get props => [request];
}

final class ProjectProgressReportUpdated extends ProjectProgressReportEvent {
  const ProjectProgressReportUpdated({required this.request});

  final ProjectProgressReportRequest request;

  @override
  List<Object?> get props => [request];
}

/// Đưa trạng thái thao tác tạo/cập nhật về initial sau khi UI xử lý message.
final class ProjectProgressReportActionStateCleared
    extends ProjectProgressReportEvent {
  const ProjectProgressReportActionStateCleared();
}

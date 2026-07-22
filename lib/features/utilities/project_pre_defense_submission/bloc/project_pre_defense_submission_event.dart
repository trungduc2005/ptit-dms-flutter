import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';

sealed class ProjectPreDefenseSubmissionEvent extends Equatable {
  const ProjectPreDefenseSubmissionEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải thông tin và lịch sử nộp đồ án trước bảo vệ.
final class ProjectPreDefenseSubmissionStarted
    extends ProjectPreDefenseSubmissionEvent {
  const ProjectPreDefenseSubmissionStarted({
    required this.projectId,
    required this.academicYearId,
  });

  final String projectId;
  final String academicYearId;

  @override
  List<Object?> get props => [projectId, academicYearId];
}

/// Tải lại dữ liệu bằng thông tin đồ án đang được lưu trong state.
final class ProjectPreDefenseSubmissionRefreshed
    extends ProjectPreDefenseSubmissionEvent {
  const ProjectPreDefenseSubmissionRefreshed();
}

/// Upload một hoặc cả hai file đồ án và báo cáo Turnitin.
final class ProjectPreDefenseSubmissionUploaded
    extends ProjectPreDefenseSubmissionEvent {
  const ProjectPreDefenseSubmissionUploaded({required this.request});

  final ProjectPreDefenseSubmissionRequest request;

  @override
  List<Object?> get props => [request];
}

/// Đưa trạng thái upload về initial sau khi UI đã xử lý thông báo.
final class ProjectPreDefenseSubmissionUploadStateCleared
    extends ProjectPreDefenseSubmissionEvent {
  const ProjectPreDefenseSubmissionUploadStateCleared();
}

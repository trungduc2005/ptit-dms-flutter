import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';

sealed class ProjectPostDefenseSubmissionEvent extends Equatable {
  const ProjectPostDefenseSubmissionEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải thông tin và lịch sử nộp đồ án sau bảo vệ.
final class ProjectPostDefenseSubmissionStarted
    extends ProjectPostDefenseSubmissionEvent {
  const ProjectPostDefenseSubmissionStarted({
    required this.projectId,
    required this.academicYearId,
  });

  final String projectId;
  final String academicYearId;

  @override
  List<Object?> get props => [projectId, academicYearId];
}

/// Tải lại dữ liệu bằng thông tin đồ án đang được lưu trong state.
final class ProjectPostDefenseSubmissionRefreshed
    extends ProjectPostDefenseSubmissionEvent {
  const ProjectPostDefenseSubmissionRefreshed();
}

/// Upload đầy đủ các file đồ án sau bảo vệ.
final class ProjectPostDefenseSubmissionUploaded
    extends ProjectPostDefenseSubmissionEvent {
  const ProjectPostDefenseSubmissionUploaded({required this.request});

  final ProjectPostDefenseSubmissionRequest request;

  @override
  List<Object?> get props => [request];
}

/// Đưa trạng thái upload về initial sau khi UI đã xử lý thông báo.
final class ProjectPostDefenseSubmissionUploadStateCleared
    extends ProjectPostDefenseSubmissionEvent {
  const ProjectPostDefenseSubmissionUploadStateCleared();
}

import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

abstract class ProjectRepository {
  /// Kiểm tra sinh viên hiện tại có đồ án trong năm học không.
  Future<Project?> checkProject({required String academicYearId});

  /// Đăng ký đồ án mới.
  Future<Project> registerProject({
    required ProjectRegistrationRequest request,
  });

  /// Cập nhật đồ án (khi status = project_needs_revision).
  Future<Project> updateProject({required ProjectRegistrationRequest request});

  /// Thành viên xác nhận tham gia nhóm.
  Future<void> approveProjectMembership({
    required String projectId,
    required String studentRef,
  });

  /// Thành viên từ chối tham gia nhóm.
  Future<void> rejectProjectMembership({
    required String projectId,
    required String studentRef,
    String? reason,
  });
}

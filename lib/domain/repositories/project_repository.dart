import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

abstract class ProjectRepository {
  /// Kiểm tra và lấy đồ án của sinh viên trong năm học.
  Future<Project?> checkProject({
    required String academicYearId,
    required String studentId,
  });

  /// Danh sách đợt đăng ký đồ án giống form web.
  Future<List<ProjectPeriodOption>> getProjectPeriods();

  /// Danh sách giảng viên có thể hướng dẫn trong năm học.
  Future<List<ProjectGuiderOption>> getProjectGuiders({
    required String academicYearId,
  });

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

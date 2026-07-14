import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

class ProjectRemoteDataSource {
  ProjectRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/projects/check-project?academicYearId=...
  /// Kiểm tra sinh viên hiện tại có đồ án trong năm học không.
  /// Trả về null nếu chưa có.
  Future<Project?> checkProject({required String academicYearId}) async {
    final response = await _dio.get(
      '/projects/check-project',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final json = asNullableJsonMap(response.data, unwrapData: true);
    if (json == null) return null;

    return Project.fromJson(json);
  }

  /// POST /api/projects
  /// Đăng ký đồ án mới. Trả về Project vừa tạo.
  Future<Project> registerProject({
    required ProjectRegistrationRequest request,
  }) async {
    final response = await _dio.post(
      '/projects',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return Project.fromJson(asJsonMap(response.data, unwrapData: true));
  }

  /// PUT /api/projects
  /// Cập nhật đồ án (chỉ cho phép khi status = project_needs_revision).
  Future<Project> updateProject({
    required ProjectRegistrationRequest request,
  }) async {
    final response = await _dio.put(
      '/projects',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return Project.fromJson(asJsonMap(response.data, unwrapData: true));
  }

  /// POST /api/projects/:projectId/members/:studentRef/approve
  /// Thành viên xác nhận tham gia nhóm.
  Future<void> approveProjectMembership({
    required String projectId,
    required String studentRef,
  }) async {
    await _dio.post(
      '/projects/$projectId/members/$studentRef/approve',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
  }

  /// POST /api/projects/:projectId/members/:studentRef/reject
  /// Thành viên từ chối tham gia nhóm.
  Future<void> rejectProjectMembership({
    required String projectId,
    required String studentRef,
    String? reason,
  }) async {
    await _dio.post(
      '/projects/$projectId/members/$studentRef/reject',
      data: reason != null ? {'reason': reason} : null,
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
  }
}
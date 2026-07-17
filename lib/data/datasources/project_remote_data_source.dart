import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_option.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

class ProjectRemoteDataSource {
  ProjectRemoteDataSource(this._dio);

  final Dio _dio;

  /// Kiểm tra và lấy hồ sơ đồ án của sinh viên trong năm học.
  ///
  /// Backend tách việc này thành hai endpoint:
  /// - GET /api/projects/check-project chỉ trả `{ register: bool }`.
  /// - GET /api/projects/:studentId mới trả đầy đủ thông tin đồ án.
  Future<Project?> checkProject({
    required String academicYearId,
    required String studentId,
  }) async {
    final checkResponse = await _dio.get(
      '/projects/check-project',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final checkJson = asNullableJsonMap(checkResponse.data, unwrapData: true);
    if (checkJson == null || checkJson['register'] != true) return null;

    final projectResponse = await _dio.get(
      '/projects/${Uri.encodeComponent(studentId)}',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final projectJson = asNullableJsonMap(
      projectResponse.data,
      unwrapData: true,
    );
    if (projectJson == null) {
      throw const FormatException(
        'Backend xác nhận đã đăng ký nhưng không trả thông tin đồ án.',
      );
    }

    final nestedProject = projectJson['project'];
    final data = nestedProject is Map
        ? Map<String, dynamic>.from(nestedProject)
        : projectJson;

    final hasProjectIdentity = [
      data['_id'],
      data['projectId'],
      data['projectName'],
    ].any((value) => value != null && value.toString().trim().isNotEmpty);
    if (!hasProjectIdentity) {
      throw const FormatException('Thông tin đồ án không có định danh.');
    }

    return Project.fromJson(data);
  }

  /// GET /api/periods?type=project
  Future<List<ProjectPeriodOption>> getProjectPeriods() async {
    final response = await _dio.get(
      '/periods',
      queryParameters: const {'type': 'project'},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return asJsonList(response.data)
        .map(ProjectPeriodOption.fromJson)
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  /// GET /api/lecturers/guiders?academicYearId=...
  Future<List<ProjectGuiderOption>> getProjectGuiders({
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/lecturers/guiders',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return asJsonList(response.data)
        .map(ProjectGuiderOption.fromJson)
        .where((item) => item.lecturerId.trim().isNotEmpty)
        .toList(growable: false);
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

    return Project.fromJson(_extractProject(response.data));
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

    return Project.fromJson(_extractProject(response.data));
  }

  Map<String, dynamic> _extractProject(Object? data) {
    final json = asJsonMap(data, unwrapData: true);
    final project = json['project'];
    if (project is Map) {
      return Map<String, dynamic>.from(project);
    }
    return json;
  }

  /// POST /api/projects/:projectId/members/:studentRef/approve
  /// Thành viên xác nhận tham gia nhóm.
  Future<void> approveProjectMembership({
    required String projectId,
    required String studentRef,
  }) async {
    final encodedProjectId = Uri.encodeComponent(projectId);
    final encodedStudentRef = Uri.encodeComponent(studentRef);

    await _dio.post(
      '/projects/$encodedProjectId/members/$encodedStudentRef/approve',
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
    final encodedProjectId = Uri.encodeComponent(projectId);
    final encodedStudentRef = Uri.encodeComponent(studentRef);

    await _dio.post(
      '/projects/$encodedProjectId/members/$encodedStudentRef/reject',
      data: reason != null ? {'reason': reason} : null,
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
  }
}

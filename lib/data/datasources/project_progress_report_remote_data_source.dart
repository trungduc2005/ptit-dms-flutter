import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';

class ProjectProgressReportRemoteDataSource {
  ProjectProgressReportRemoteDataSource(this._dio);

  static const _basePath = '/projects/reports';

  final Dio _dio;

  Future<List<ProjectProgressReport>> getReports({
    required String projectObjectId,
    required String academicYearId,
  }) async {
    final response = await _dio.get<Object?>(
      '$_basePath/$projectObjectId',
      queryParameters: {'academicYearId': academicYearId},
    );

    return _parseList(
      response.data,
      ProjectProgressReport.fromJson,
      label: 'danh sách báo cáo tiến độ',
    );
  }

  Future<List<ProjectReportReply>> getReplies({
    required String projectId,
    required String academicYearId,
  }) async {
    final response = await _dio.get<Object?>(
      '$_basePath/replies/$projectId',
      queryParameters: {'academicYearId': academicYearId},
    );

    return _parseList(
      response.data,
      ProjectReportReply.fromJson,
      label: 'danh sách phản hồi báo cáo',
    );
  }

  Future<ProjectProgressReport> createReport({
    required ProjectProgressReportRequest request,
  }) async {
    final response = await _dio.post<Object?>(
      _basePath,
      data: request.toJson(),
    );
    final envelope = _asJsonObject(
      response.data,
      label: 'kết quả tạo báo cáo tiến độ',
    );

    return ProjectProgressReport.fromJson(
      _asJsonObject(
        envelope['projectReport'],
        label: 'báo cáo tiến độ vừa tạo',
      ),
    );
  }

  Future<ProjectProgressReport> updateReport({
    required ProjectProgressReportRequest request,
  }) async {
    final response = await _dio.put<Object?>(_basePath, data: request.toJson());

    return ProjectProgressReport.fromJson(
      _asJsonObject(response.data, label: 'kết quả cập nhật báo cáo tiến độ'),
    );
  }
}

List<T> _parseList<T>(
  Object? data,
  T Function(Map<String, dynamic>) fromJson, {
  required String label,
}) {
  if (data is! List) {
    throw FormatException('$label không đúng định dạng.');
  }

  return data
      .map(
        (item) => fromJson(_asJsonObject(item, label: 'phần tử trong $label')),
      )
      .toList(growable: false);
}

Map<String, dynamic> _asJsonObject(Object? data, {required String label}) {
  if (data is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(data);
}

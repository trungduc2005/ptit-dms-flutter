import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/domain/entities/project_result.dart';

class ProjectResultRemoteDataSource {
  ProjectResultRemoteDataSource(this._dio);

  static const _basePath = '/projects/evaluations-result';

  final Dio _dio;

  Future<ProjectResult> getProjectResult({required String projectId}) async {
    final response = await _dio.get<Object?>(
      '$_basePath/$projectId/clo-results',
    );

    return ProjectResult.fromJson(
      _asJsonObject(response.data, label: 'kết quả đồ án tốt nghiệp'),
    );
  }
}

Map<String, dynamic> _asJsonObject(Object? data, {required String label}) {
  if (data is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(data);
}

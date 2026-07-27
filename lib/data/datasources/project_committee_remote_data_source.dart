import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/domain/entities/project_committee.dart';

class ProjectCommitteeRemoteDataSource {
  ProjectCommitteeRemoteDataSource(this._dio);

  static const _basePath = '/projects/committees';

  final Dio _dio;

  Future<ProjectCommittee> getMyProjectCommittee({
    required String academicYearId,
  }) async {
    final response = await _dio.get<Object?>(
      '$_basePath/me',
      queryParameters: {'academicYearId': academicYearId},
    );

    return ProjectCommittee.fromJson(
      _asJsonObject(response.data, label: 'thông tin hội đồng đồ án'),
    );
  }
}

Map<String, dynamic> _asJsonObject(Object? data, {required String label}) {
  if (data is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(data);
}

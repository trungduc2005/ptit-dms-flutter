import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

class StudentSearchRemoteDataSource {
  StudentSearchRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<StudentSearchResult>> searchInternEligibleStudents({
    required String query,
    required String academicYearId,
  }) async {
    final keyword = query.trim();
    if (keyword.isEmpty) return const [];

    final response = await _dio.get(
      '/students/search',
      queryParameters: {
        'q': keyword,
        'academicYearId': academicYearId,
        'canRegisterInternship': true,
      },
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final items = asJsonList(response.data);
    return items.map(StudentSearchResult.fromJson).toList(growable: false);
  }
}

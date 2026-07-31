import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_member_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';

class ResearchRemoteDataSource {
  ResearchRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/researches/user?yearId=...&type=...
  Future<List<Research>> getUserResearches({
    required String yearId,
    required String type,
  }) async {
    final response = await _dio.get(
      '/researches/user',
      queryParameters: {'yearId': yearId, 'type': type},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return asJsonList(
      response.data,
    ).map(Research.fromJson).toList(growable: false);
  }

  Future<List<ResearchMemberOption>> searchLecturers({
    required String query,
  }) async {
    final keyword = query.trim();
    if (keyword.length < 3) return const [];

    final response = await _dio.get(
      '/lecturers/search',
      queryParameters: {'q': keyword},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return asJsonList(response.data)
        .map(ResearchMemberOption.fromLecturerJson)
        .where((option) => option.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<ResearchMemberOption>> searchStudents({
    required String query,
    required String academicYearId,
  }) async {
    final keyword = query.trim();
    if (keyword.length < 3) return const [];

    final response = await _dio.get(
      '/students/search',
      queryParameters: {
        'q': keyword,
        if (academicYearId.trim().isNotEmpty)
          'academicYearId': academicYearId.trim(),
      },
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return asJsonList(response.data)
        .map(ResearchMemberOption.fromStudentJson)
        .where((option) => option.id.isNotEmpty)
        .toList(growable: false);
  }

  /// POST /api/researches
  Future<Research> createResearch({
    required ResearchRegistrationRequest request,
  }) async {
    final response = await _dio.post(
      '/researches',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return Research.fromJson(_extractResearch(response.data));
  }

  /// PUT /api/researches/:researchId
  Future<Research> updateResearch({
    required String researchId,
    required ResearchRegistrationRequest request,
  }) async {
    final encodedResearchId = Uri.encodeComponent(researchId);
    final response = await _dio.put(
      '/researches/$encodedResearchId',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return Research.fromJson(_extractResearch(response.data));
  }

  Map<String, dynamic> _extractResearch(Object? data) {
    final responseData = asNullableJsonMap(data, unwrapData: true);
    if (responseData == null) {
      throw const FormatException(
        'Kết quả đăng ký nghiên cứu khoa học không đúng định dạng.',
      );
    }

    final research =
        asNullableJsonMap(responseData['research'], unwrapData: false) ??
        responseData;
    final hasIdentity = [
      research['_id'],
      research['researchId'],
    ].any((value) => value != null && value.toString().trim().isNotEmpty);

    if (!hasIdentity) {
      throw const FormatException(
        'Thông tin nghiên cứu khoa học không có định danh.',
      );
    }

    return research;
  }
}

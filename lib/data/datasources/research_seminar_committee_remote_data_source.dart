import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/domain/entities/research_seminar_committee.dart';

class ResearchSeminarCommitteeRemoteDataSource {
  ResearchSeminarCommitteeRemoteDataSource(this._dio);

  static const _path =
      '/researches/committees/my/presentationResearchCommittee';

  final Dio _dio;

  Future<ResearchSeminarCommitteeResult> getMyCommittee({
    required String yearId,
    String? researchId,
  }) async {
    final normalizedYearId = yearId.trim();
    final normalizedResearchId = researchId?.trim();

    if (normalizedYearId.isEmpty) {
      throw const FormatException(
        'Thiếu thông tin năm học của hội đồng hội thảo.',
      );
    }

    final response = await _dio.get<Object?>(
      _path,
      queryParameters: {
        'yearId': normalizedYearId,
        if (normalizedResearchId != null && normalizedResearchId.isNotEmpty)
          'researchId': normalizedResearchId,
      },
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final data = response.data;
    if (data is! Map) {
      throw const FormatException(
        'Dữ liệu hội đồng hội thảo không đúng định dạng.',
      );
    }

    return ResearchSeminarCommitteeResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}

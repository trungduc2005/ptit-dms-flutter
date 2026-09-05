import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';

class ResearchFinalCommitteeRemoteDataSource {
  ResearchFinalCommitteeRemoteDataSource(this._dio);

  static const _path = '/researches/committees/my/finalResearchCommittee';

  final Dio _dio;

  Future<ResearchFinalCommitteeResult> getMyCommittee({
    required String yearId,
    String? researchId,
  }) async {
    final normalizedYearId = yearId.trim();
    final normalizedResearchId = researchId?.trim();

    if (normalizedYearId.isEmpty) {
      throw const FormatException(
        'Thiếu thông tin năm học của hội đồng nghiệm thu.',
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
        'Dữ liệu hội đồng nghiệm thu không đúng định dạng.',
      );
    }

    return ResearchFinalCommitteeResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}

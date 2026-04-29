import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/eligibility.dart';

class EligibilityRemoteDataSource {
  EligibilityRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Eligibility> getRegistrationEligibility({
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/info/eligibility',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return Eligibility.fromJson(asJsonMap(response.data, unwrapData: true));
  }
}

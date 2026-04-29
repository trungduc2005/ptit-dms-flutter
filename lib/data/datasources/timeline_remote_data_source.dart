import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';

class TimelineRemoteDataSource {
  TimelineRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Timeline>> getInternTimelines({
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/interns/timelines',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final items = asJsonList(response.data);

    return items.map(Timeline.fromJson).toList(growable: false);
  }
}

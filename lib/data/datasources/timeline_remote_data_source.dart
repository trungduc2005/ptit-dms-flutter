import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/models/timeline_model.dart';

class TimelineRemoteDataSource {
  TimelineRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TimelineModel>> getInternTimelines({
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/interns/timelines',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(
        extra: const {requiresBearerAuthKey: true},
      ),
    );

    final items = _asJsonList(response.data);

    return items.map(TimelineModel.fromJson).toList(growable: false);
  }

  List<Map<String, dynamic>> _asJsonList(Object? data) {
    Object? source = data;

    if (data is Map && data['data'] is List) {
      source = data['data'];
    }

    if (source is List) {
      return source
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    return const [];
  }
}

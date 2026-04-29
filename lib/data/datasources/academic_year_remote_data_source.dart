import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';

class AcademicYearRemoteDataSource {
  AcademicYearRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AcademicYearOption>> getInternAcademicYears() async {
    final response = await _dio.get(
      '/academic-years/options/interns',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final items = asJsonList(response.data);

    return items.map(AcademicYearOption.fromJson).toList();
  }
}

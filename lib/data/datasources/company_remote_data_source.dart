import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Company>> getCompanies({
    required String academicYearCode,
    String search = '',
  }) async {
    final response = await _dio.get(
      '/public/internship-companies/$academicYearCode',
      queryParameters: {'search': search},
    );

    final json = asJsonMap(response.data, unwrapData: true);
    final items = asJsonList(json['data']);

    return items.map(Company.fromJson).toList(growable: false);
  }
}

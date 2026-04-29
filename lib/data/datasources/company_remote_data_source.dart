import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Company>> getCompanies() async {
    final response = await _dio.get(
      '/companies',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
    final items = asJsonList(response.data);

    return items.map(Company.fromJson).toList(growable: false);
  }
}

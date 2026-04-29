import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CompanyModel>> getCompanies() async {
    final response = await _dio.get(
      '/companies',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
    final items = asJsonList(response.data);

    return items.map(CompanyModel.fromJson).toList(growable: false);
  }
}

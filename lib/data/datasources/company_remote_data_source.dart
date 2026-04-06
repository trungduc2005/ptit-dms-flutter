import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CompanyModel>> getCompanies() async {
    final response = await _dio.get('/companies');
    final items = _asJsonList(response.data);

    return items.map(CompanyModel.fromJson).toList(growable: false);
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

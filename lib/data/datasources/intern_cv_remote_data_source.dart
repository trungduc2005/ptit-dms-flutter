import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/models/intern_cv_upload_result_model.dart';

class InternCvRemoteDataSource {
  InternCvRemoteDataSource(this._dio);

  final Dio _dio;

  Future<InternCvUploadResultModel> uploadCv({
    required String academicYearId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'cvFile': await MultipartFile.fromFile(
        filePath,
        filename: _extractFileName(filePath),
      ),
    });

    final response = await _dio.post(
      '/interns/registrations/cv',
      queryParameters: {'academicYearId': academicYearId},
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        extra: const {requiresBearerAuthKey: true},
      ),
    );

    return InternCvUploadResultModel.fromJson(_asJsonMap(response.data));
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    Object? source = data;

    if (data is Map && data['data'] is Map) {
      source = data['data'];
    }

    if (source is Map<String, dynamic>) {
      return source;
    }

    if (source is Map) {
      return Map<String, dynamic>.from(source);
    }

    return <String, dynamic>{};
  }

  String _extractFileName(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final segments = normalized.split('/');

    if (segments.isEmpty) {
      return filePath;
    }

    return segments.last;
  }
}

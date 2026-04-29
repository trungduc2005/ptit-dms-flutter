import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/data/models/intern_cv_upload_result_model.dart';

class InternCvRemoteDataSource {
  InternCvRemoteDataSource(this._dio);

  final Dio _dio;

  Future<InternCvUploadResultModel> uploadCv({
    required String academicYearId,
    required String filePath,
    String? studentId,
  }) async {
    final normalizedStudentId = studentId?.trim() ?? '';

    final formData = FormData.fromMap({
      'cvFile': await MultipartFile.fromFile(
        filePath,
        filename: _extractFileName(filePath),
      ),
      if (normalizedStudentId.isNotEmpty) 'studentId': normalizedStudentId,
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

    return InternCvUploadResultModel.fromJson(
      asJsonMap(response.data, unwrapData: true),
    );
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

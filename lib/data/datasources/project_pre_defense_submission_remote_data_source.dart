import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';

class ProjectPreDefenseSubmissionRemoteDataSource {
  ProjectPreDefenseSubmissionRemoteDataSource(this._dio);

  static const _basePath = '/projects/pre-report-files';

  final Dio _dio;

  Future<ProjectPreDefenseSubmission> getSubmission({
    required String projectId,
    required String academicYearId,
  }) async {
    final response = await _dio.get<Object?>(
      '$_basePath/$projectId',
      queryParameters: {'academicYearId': academicYearId},
    );

    return ProjectPreDefenseSubmission.fromJson(
      _asJsonObject(response.data, label: 'dữ liệu nộp đồ án'),
    );
  }

  Future<void> uploadSubmission({
    required ProjectPreDefenseSubmissionRequest request,
    ProgressCallback? onSendProgress,
  }) async {
    request.validate();

    final formData = FormData.fromMap({
      'projectId': request.projectId.trim(),
      'academicYearId': request.academicYearId.trim(),
      if (request.thesisFile != null)
        'thesisFile': await _toMultipartFile(request.thesisFile!),
      if (request.turnitinReportFile != null)
        'turnitinReportFile': await _toMultipartFile(
          request.turnitinReportFile!,
        ),
    });

    final response = await _dio.post<Object?>(
      '$_basePath/upload',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      onSendProgress: onSendProgress,
    );

    final envelope = _asJsonObject(response.data, label: 'kết quả nộp đồ án');
    if (envelope['success'] != true) {
      throw const FormatException('Kết quả nộp đồ án không thành công.');
    }
  }

  Future<MultipartFile> _toMultipartFile(
    ProjectPreDefenseUploadFile file,
  ) async {
    final bytes = file.bytes;
    if (bytes != null) {
      return MultipartFile.fromBytes(bytes, filename: file.fileName.trim());
    }

    final path = file.path;
    if (path == null || path.trim().isEmpty) {
      throw const FormatException('Không thể đọc file đã chọn.');
    }

    return MultipartFile.fromFile(path, filename: file.fileName.trim());
  }
}

Map<String, dynamic> _asJsonObject(Object? data, {required String label}) {
  if (data is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(data);
}

import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';

class ResearchPreAcceptanceReportRemoteDataSource {
  ResearchPreAcceptanceReportRemoteDataSource(this._dio);

  static const _basePath = '/researches/pre-acceptance-reports';

  final Dio _dio;

  Future<List<ResearchPreAcceptanceReport>> getReports({
    required String researchId,
    required String yearId,
  }) async {
    final normalizedResearchId = researchId.trim();
    final normalizedYearId = yearId.trim();
    if (normalizedResearchId.isEmpty || normalizedYearId.isEmpty) {
      throw const FormatException(
        'Thiếu thông tin đề tài nghiên cứu hoặc năm học.',
      );
    }

    final response = await _dio.get<Object?>(
      '$_basePath/${Uri.encodeComponent(normalizedResearchId)}',
      queryParameters: {'yearId': normalizedYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final envelope = _asJsonObject(
      response.data,
      label: 'dữ liệu báo cáo trước nghiệm thu',
    );
    if (envelope['success'] != true) {
      throw const FormatException(
        'Kết quả lấy báo cáo trước nghiệm thu không thành công.',
      );
    }

    final submissions = envelope['submissions'];
    if (submissions is! List) {
      throw const FormatException(
        'Danh sách báo cáo trước nghiệm thu không đúng định dạng.',
      );
    }

    return submissions
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Báo cáo trước nghiệm thu không đúng định dạng.',
            );
          }

          return ResearchPreAcceptanceReport.fromJson(
            Map<String, dynamic>.from(item),
          );
        })
        .toList(growable: false);
  }

  Future<void> uploadReport({
    required ResearchPreAcceptanceReportRequest request,
    ProgressCallback? onSendProgress,
  }) async {
    request.validate();

    final formData = FormData.fromMap({
      'researchId': request.researchId.trim(),
      'yearId': request.yearId.trim(),
      'reportFile': await _toMultipartFile(request.reportFile),
      'turnitinReportFile': await _toMultipartFile(request.turnitinReportFile),
    });

    final response = await _dio.post<Object?>(
      '$_basePath/upload',
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        extra: const {requiresBearerAuthKey: true},
      ),
      onSendProgress: onSendProgress,
    );

    final envelope = _asJsonObject(
      response.data,
      label: 'kết quả nộp báo cáo trước nghiệm thu',
    );
    if (envelope['success'] != true) {
      throw const FormatException(
        'Kết quả nộp báo cáo trước nghiệm thu không thành công.',
      );
    }
  }

  Future<MultipartFile> _toMultipartFile(
    ResearchPreAcceptanceUploadFile file,
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

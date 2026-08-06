import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';

class ResearchPostAcceptanceReportRemoteDataSource {
  ResearchPostAcceptanceReportRemoteDataSource(this._dio);

  static const _basePath = '/researches/post-acceptance-reports';

  final Dio _dio;

  Future<List<ResearchPostAcceptanceReport>> getReports({
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
      label: 'dữ liệu báo cáo sau nghiệm thu',
    );
    if (envelope['success'] != true) {
      throw const FormatException(
        'Kết quả lấy báo cáo sau nghiệm thu không thành công.',
      );
    }

    final submissions = envelope['submissions'];
    if (submissions is! List) {
      throw const FormatException(
        'Danh sách báo cáo sau nghiệm thu không đúng định dạng.',
      );
    }

    return submissions
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Báo cáo sau nghiệm thu không đúng định dạng.',
            );
          }

          return ResearchPostAcceptanceReport.fromJson(
            Map<String, dynamic>.from(item),
          );
        })
        .toList(growable: false);
  }

  Future<void> uploadReport({
    required ResearchPostAcceptanceReportRequest request,
    ProgressCallback? onSendProgress,
  }) async {
    request.validate();

    final formDataMap = <String, dynamic>{
      'researchId': request.researchId.trim(),
      'yearId': request.yearId.trim(),
      'reportFile': await _toMultipartFile(request.reportFile),
      'acceptanceMinutesFile': await _toMultipartFile(
        request.acceptanceMinutesFile,
      ),
      'acceptanceCommitteeListFile': await _toMultipartFile(
        request.acceptanceCommitteeListFile,
      ),
      'proposalFile': await _toMultipartFile(request.proposalFile),
      'revisionExplanationFile': await _toMultipartFile(
        request.revisionExplanationFile,
      ),
      'acceptanceDecisionFile': await _toMultipartFile(
        request.acceptanceDecisionFile,
      ),
    };
    final paperFile = request.paperFile;
    if (paperFile != null) {
      formDataMap['paperFile'] = await _toMultipartFile(paperFile);
    }

    final response = await _dio.post<Object?>(
      '$_basePath/upload',
      data: FormData.fromMap(formDataMap),
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        extra: const {requiresBearerAuthKey: true},
      ),
      onSendProgress: onSendProgress,
    );

    final envelope = _asJsonObject(
      response.data,
      label: 'kết quả nộp báo cáo sau nghiệm thu',
    );
    if (envelope['success'] != true) {
      throw const FormatException(
        'Kết quả nộp báo cáo sau nghiệm thu không thành công.',
      );
    }
  }

  Future<ResearchPostAcceptanceReportDownload> downloadFile({
    required String fileKey,
    required String yearId,
  }) async {
    final normalizedFileKey = fileKey.trim();
    final normalizedYearId = yearId.trim();
    if (normalizedFileKey.isEmpty || normalizedYearId.isEmpty) {
      throw const FormatException('Thiếu đường dẫn tệp báo cáo hoặc năm học.');
    }

    final response = await _dio.get<List<int>>(
      '$_basePath/download',
      queryParameters: {
        'fileKey': normalizedFileKey,
        'yearId': normalizedYearId,
      },
      options: Options(
        responseType: ResponseType.bytes,
        extra: const {requiresBearerAuthKey: true},
      ),
    );

    final bytes = _asBytes(response.data);
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException(
        'Không nhận được dữ liệu tệp báo cáo sau nghiệm thu hợp lệ.',
      );
    }

    return ResearchPostAcceptanceReportDownload(
      bytes: bytes,
      fileName:
          _extractFileName(response.headers) ??
          _fallbackFileName(normalizedFileKey),
      contentType: response.headers.value(Headers.contentTypeHeader),
    );
  }

  Future<MultipartFile> _toMultipartFile(
    ResearchPostAcceptanceUploadFile file,
  ) async {
    final bytes = file.bytes;
    if (bytes != null) {
      return MultipartFile.fromBytes(bytes, filename: file.fileName.trim());
    }

    final path = file.path;
    if (path == null || path.trim().isEmpty) {
      throw const FormatException('Không thể đọc tệp đã chọn.');
    }

    return MultipartFile.fromFile(path, filename: file.fileName.trim());
  }

  Uint8List? _asBytes(Object? data) {
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    return null;
  }

  String? _extractFileName(Headers headers) {
    final contentDisposition = headers.value('content-disposition');
    if (contentDisposition == null || contentDisposition.isEmpty) return null;

    final utf8Match = RegExp(
      r"filename\*=UTF-8''([^;]+)",
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    if (utf8Match != null) {
      return Uri.decodeComponent(utf8Match.group(1)!);
    }

    final basicMatch = RegExp(
      r'filename="?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    final fileName = basicMatch?.group(1)?.trim();
    return fileName == null || fileName.isEmpty
        ? null
        : Uri.decodeComponent(fileName);
  }

  String _fallbackFileName(String fileKey) {
    final segments = fileKey.split('/');
    final fileName = segments.isEmpty ? '' : segments.last.trim();
    return fileName.isEmpty ? 'research-post-acceptance-report' : fileName;
  }
}

Map<String, dynamic> _asJsonObject(Object? data, {required String label}) {
  if (data is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(data);
}

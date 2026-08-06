import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_post_acceptance_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_post_acceptance_report_repository.dart';

class ResearchPostAcceptanceReportRepositoryImpl
    implements ResearchPostAcceptanceReportRepository {
  ResearchPostAcceptanceReportRepositoryImpl(
    this._remoteDataSource,
    this._mapper,
  );

  final ResearchPostAcceptanceReportRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<ResearchPostAcceptanceReport>> getReports({
    required String researchId,
    required String yearId,
  }) {
    return _guard(
      () =>
          _remoteDataSource.getReports(researchId: researchId, yearId: yearId),
      invalidDataMessage: 'Dữ liệu báo cáo sau nghiệm thu không hợp lệ.',
    );
  }

  @override
  Future<void> uploadReport({
    required ResearchPostAcceptanceReportRequest request,
    ResearchPostAcceptanceUploadProgressCallback? onSendProgress,
  }) {
    return _guard(
      () => _remoteDataSource.uploadReport(
        request: request,
        onSendProgress: onSendProgress,
      ),
      invalidDataMessage:
          'Thông tin hoặc tệp báo cáo sau nghiệm thu không hợp lệ.',
    );
  }

  @override
  Future<ResearchPostAcceptanceReportDownload> downloadFile({
    required String fileKey,
    required String yearId,
  }) {
    return _guard(
      () => _remoteDataSource.downloadFile(fileKey: fileKey, yearId: yearId),
      invalidDataMessage:
          'Thông tin hoặc dữ liệu tệp báo cáo sau nghiệm thu không hợp lệ.',
    );
  }

  Future<T> _guard<T>(
    Future<T> Function() action, {
    required String invalidDataMessage,
  }) async {
    try {
      return await action();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          invalidDataMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

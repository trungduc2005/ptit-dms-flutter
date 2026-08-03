import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_pre_acceptance_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_pre_acceptance_report_repository.dart';

class ResearchPreAcceptanceReportRepositoryImpl
    implements ResearchPreAcceptanceReportRepository {
  ResearchPreAcceptanceReportRepositoryImpl(
    this._remoteDataSource,
    this._mapper,
  );

  final ResearchPreAcceptanceReportRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<ResearchPreAcceptanceReport>> getReports({
    required String researchId,
    required String yearId,
  }) {
    return _guard(
      () =>
          _remoteDataSource.getReports(researchId: researchId, yearId: yearId),
      invalidDataMessage: 'Dữ liệu báo cáo trước nghiệm thu không hợp lệ.',
    );
  }

  @override
  Future<void> uploadReport({
    required ResearchPreAcceptanceReportRequest request,
    ResearchPreAcceptanceUploadProgressCallback? onSendProgress,
  }) {
    return _guard(
      () => _remoteDataSource.uploadReport(
        request: request,
        onSendProgress: onSendProgress,
      ),
      invalidDataMessage:
          'Thông tin hoặc file báo cáo trước nghiệm thu không hợp lệ.',
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

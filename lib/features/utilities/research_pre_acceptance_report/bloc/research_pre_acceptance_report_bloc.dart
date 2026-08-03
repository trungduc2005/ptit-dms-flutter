import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_pre_acceptance_report_repository.dart';

import 'research_pre_acceptance_report_event.dart';
import 'research_pre_acceptance_report_state.dart';

export 'research_pre_acceptance_report_event.dart';
export 'research_pre_acceptance_report_state.dart';

class ResearchPreAcceptanceReportBloc
    extends
        Bloc<
          ResearchPreAcceptanceReportEvent,
          ResearchPreAcceptanceReportState
        > {
  ResearchPreAcceptanceReportBloc({
    required ResearchPreAcceptanceReportRepository repository,
  }) : _repository = repository,
       super(const ResearchPreAcceptanceReportState()) {
    on<ResearchPreAcceptanceReportStarted>(_onStarted);
    on<ResearchPreAcceptanceReportRefreshed>(_onRefreshed);
    on<ResearchPreAcceptanceReportUploaded>(_onUploaded);
    on<ResearchPreAcceptanceReportUploadStateCleared>(_onUploadStateCleared);
  }

  final ResearchPreAcceptanceReportRepository _repository;
  int _loadGeneration = 0;

  Future<void> _onStarted(
    ResearchPreAcceptanceReportStarted event,
    Emitter<ResearchPreAcceptanceReportState> emit,
  ) async {
    final researchId = event.researchId.trim();
    final yearId = event.yearId.trim();
    final validationMessage = _validateIdentifiers(
      researchId: researchId,
      yearId: yearId,
    );

    if (validationMessage != null) {
      _loadGeneration++;
      emit(
        state.copyWith(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.failure,
          researchId: researchId,
          yearId: yearId,
          reports: const [],
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(
      emit,
      researchId: researchId,
      yearId: yearId,
      clearReports: researchId != state.researchId || yearId != state.yearId,
    );
  }

  Future<void> _onRefreshed(
    ResearchPreAcceptanceReportRefreshed event,
    Emitter<ResearchPreAcceptanceReportState> emit,
  ) async {
    final validationMessage = _validateIdentifiers(
      researchId: state.researchId,
      yearId: state.yearId,
    );
    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.failure,
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(
      emit,
      researchId: state.researchId,
      yearId: state.yearId,
      clearReports: false,
    );
  }

  Future<void> _load(
    Emitter<ResearchPreAcceptanceReportState> emit, {
    required String researchId,
    required String yearId,
    required bool clearReports,
  }) async {
    final generation = ++_loadGeneration;
    emit(
      state.copyWith(
        loadStatus: ResearchPreAcceptanceReportLoadStatus.loading,
        researchId: researchId,
        yearId: yearId,
        reports: clearReports ? const [] : state.reports,
        loadErrorMessage: null,
      ),
    );

    try {
      final reports = await _repository.getReports(
        researchId: researchId,
        yearId: yearId,
      );
      if (!_canEmitLoad(emit, generation, researchId, yearId)) return;

      emit(
        state.copyWith(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.success,
          reports: List<ResearchPreAcceptanceReport>.unmodifiable(reports),
          loadErrorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (!_canEmitLoad(emit, generation, researchId, yearId)) return;
      emit(
        state.copyWith(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.failure,
          loadErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (!_canEmitLoad(emit, generation, researchId, yearId)) return;
      emit(
        state.copyWith(
          loadStatus: ResearchPreAcceptanceReportLoadStatus.failure,
          loadErrorMessage: 'Không thể tải báo cáo trước nghiệm thu.',
        ),
      );
    }
  }

  Future<void> _onUploaded(
    ResearchPreAcceptanceReportUploaded event,
    Emitter<ResearchPreAcceptanceReportState> emit,
  ) async {
    final validationMessage = _validateRequest(event.request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.failure,
          uploadProgress: 0,
          uploadMessage: validationMessage,
        ),
      );
      return;
    }

    final researchId = event.request.researchId.trim();
    final yearId = event.request.yearId.trim();
    emit(
      state.copyWith(
        uploadStatus: ResearchPreAcceptanceReportUploadStatus.uploading,
        uploadProgress: 0,
        uploadMessage: null,
      ),
    );

    var latestProgress = 0.0;
    try {
      await _repository.uploadReport(
        request: event.request,
        onSendProgress: (sentBytes, totalBytes) {
          if (emit.isDone || isClosed || totalBytes <= 0 || sentBytes < 0) {
            return;
          }
          final progress = (sentBytes / totalBytes).clamp(0.0, 1.0);
          if (progress <= latestProgress) return;
          latestProgress = progress;
          emit(state.copyWith(uploadProgress: progress));
        },
      );
      if (emit.isDone || isClosed) return;

      List<ResearchPreAcceptanceReport>? latestReports;
      String? reloadErrorMessage;
      try {
        latestReports = await _repository.getReports(
          researchId: researchId,
          yearId: yearId,
        );
      } on AppException catch (error) {
        reloadErrorMessage = error.message;
      } catch (_) {
        reloadErrorMessage = 'Không thể tải lại lịch sử báo cáo.';
      }
      if (emit.isDone || isClosed) return;

      final isCurrentContext =
          state.researchId == researchId && state.yearId == yearId;
      emit(
        state.copyWith(
          loadStatus: isCurrentContext && latestReports != null
              ? ResearchPreAcceptanceReportLoadStatus.success
              : state.loadStatus,
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.success,
          reports: isCurrentContext && latestReports != null
              ? List<ResearchPreAcceptanceReport>.unmodifiable(latestReports)
              : state.reports,
          uploadProgress: 1,
          loadErrorMessage: isCurrentContext && reloadErrorMessage != null
              ? reloadErrorMessage
              : state.loadErrorMessage,
          uploadMessage: reloadErrorMessage == null
              ? 'Nộp báo cáo trước nghiệm thu thành công.'
              : 'Nộp báo cáo thành công nhưng không thể tải lại lịch sử.',
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.failure,
          uploadMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          uploadStatus: ResearchPreAcceptanceReportUploadStatus.failure,
          uploadMessage: 'Không thể nộp báo cáo trước nghiệm thu.',
        ),
      );
    }
  }

  String? _validateIdentifiers({
    required String researchId,
    required String yearId,
  }) {
    if (researchId.isEmpty) return 'Thiếu mã đề tài nghiên cứu.';
    if (yearId.isEmpty) return 'Thiếu năm học.';
    return null;
  }

  String? _validateRequest(ResearchPreAcceptanceReportRequest request) {
    try {
      request.validate();
      return null;
    } on FormatException catch (error) {
      return error.message;
    } catch (_) {
      return 'Thông tin hoặc file báo cáo không hợp lệ.';
    }
  }

  void _onUploadStateCleared(
    ResearchPreAcceptanceReportUploadStateCleared event,
    Emitter<ResearchPreAcceptanceReportState> emit,
  ) {
    emit(
      state.copyWith(
        uploadStatus: ResearchPreAcceptanceReportUploadStatus.initial,
        uploadProgress: 0,
        uploadMessage: null,
      ),
    );
  }

  bool _canEmitLoad(
    Emitter<ResearchPreAcceptanceReportState> emit,
    int generation,
    String researchId,
    String yearId,
  ) {
    return generation == _loadGeneration &&
        state.researchId == researchId &&
        state.yearId == yearId &&
        !emit.isDone &&
        !isClosed;
  }
}

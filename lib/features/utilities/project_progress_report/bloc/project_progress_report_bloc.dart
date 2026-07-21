import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_progress_report_repository.dart';

import 'project_progress_report_event.dart';
import 'project_progress_report_state.dart';

export 'project_progress_report_event.dart';
export 'project_progress_report_state.dart';

class ProjectProgressReportBloc
    extends Bloc<ProjectProgressReportEvent, ProjectProgressReportState> {
  ProjectProgressReportBloc({
    required ProjectProgressReportRepository repository,
  }) : _repository = repository,
       super(const ProjectProgressReportState()) {
    on<ProjectProgressReportStarted>(_onStarted);
    on<ProjectProgressReportRefreshed>(_onRefreshed);
    on<ProjectProgressReportCreated>(_onCreated);
    on<ProjectProgressReportUpdated>(_onUpdated);
    on<ProjectProgressReportActionStateCleared>(_onActionStateCleared);
  }

  final ProjectProgressReportRepository _repository;

  Future<void> _onStarted(
    ProjectProgressReportStarted event,
    Emitter<ProjectProgressReportState> emit,
  ) async {
    final projectObjectId = event.projectObjectId.trim();
    final projectId = event.projectId.trim();
    final academicYearId = event.academicYearId.trim();

    final validationMessage = _validateLoadParameters(
      projectObjectId: projectObjectId,
      projectId: projectId,
      academicYearId: academicYearId,
    );
    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ProjectProgressReportLoadStatus.failure,
          projectObjectId: projectObjectId,
          projectId: projectId,
          academicYearId: academicYearId,
          reports: const [],
          replies: const [],
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(
      emit,
      projectObjectId: projectObjectId,
      projectId: projectId,
      academicYearId: academicYearId,
    );
  }

  Future<void> _onRefreshed(
    ProjectProgressReportRefreshed event,
    Emitter<ProjectProgressReportState> emit,
  ) async {
    final validationMessage = _validateLoadParameters(
      projectObjectId: state.projectObjectId,
      projectId: state.projectId,
      academicYearId: state.academicYearId,
    );
    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ProjectProgressReportLoadStatus.failure,
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(
      emit,
      projectObjectId: state.projectObjectId,
      projectId: state.projectId,
      academicYearId: state.academicYearId,
    );
  }

  Future<void> _load(
    Emitter<ProjectProgressReportState> emit, {
    required String projectObjectId,
    required String projectId,
    required String academicYearId,
  }) async {
    emit(
      state.copyWith(
        loadStatus: ProjectProgressReportLoadStatus.loading,
        projectObjectId: projectObjectId,
        projectId: projectId,
        academicYearId: academicYearId,
        loadErrorMessage: null,
      ),
    );

    try {
      final results = await Future.wait<Object>([
        _repository.getReports(
          projectObjectId: projectObjectId,
          academicYearId: academicYearId,
        ),
        _repository.getReplies(
          projectId: projectId,
          academicYearId: academicYearId,
        ),
      ]);

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ProjectProgressReportLoadStatus.success,
          reports: results[0] as List<ProjectProgressReport>,
          replies: results[1] as List<ProjectReportReply>,
          loadErrorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ProjectProgressReportLoadStatus.failure,
          loadErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ProjectProgressReportLoadStatus.failure,
          loadErrorMessage: 'Không thể tải báo cáo tiến độ đồ án.',
        ),
      );
    }
  }

  Future<void> _onCreated(
    ProjectProgressReportCreated event,
    Emitter<ProjectProgressReportState> emit,
  ) async {
    await _save(
      emit,
      request: event.request,
      action: ProjectProgressReportAction.create,
      operation: () => _repository.createReport(request: event.request),
      successMessage: 'Tạo báo cáo tiến độ thành công.',
      failureMessage: 'Không thể tạo báo cáo tiến độ đồ án.',
    );
  }

  Future<void> _onUpdated(
    ProjectProgressReportUpdated event,
    Emitter<ProjectProgressReportState> emit,
  ) async {
    await _save(
      emit,
      request: event.request,
      action: ProjectProgressReportAction.update,
      operation: () => _repository.updateReport(request: event.request),
      successMessage: 'Cập nhật báo cáo tiến độ thành công.',
      failureMessage: 'Không thể cập nhật báo cáo tiến độ đồ án.',
    );
  }

  Future<void> _save(
    Emitter<ProjectProgressReportState> emit, {
    required ProjectProgressReportRequest request,
    required ProjectProgressReportAction action,
    required Future<ProjectProgressReport> Function() operation,
    required String successMessage,
    required String failureMessage,
  }) async {
    final validationMessage = _validateRequest(request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          actionStatus: ProjectProgressReportActionStatus.failure,
          action: action,
          savedReport: null,
          actionMessage: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        actionStatus: ProjectProgressReportActionStatus.loading,
        action: action,
        savedReport: null,
        actionMessage: null,
      ),
    );

    try {
      final report = await operation();

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          actionStatus: ProjectProgressReportActionStatus.success,
          action: action,
          reports: _mergeReport(state.reports, report),
          savedReport: report,
          actionMessage: successMessage,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ProjectProgressReportActionStatus.failure,
          action: action,
          savedReport: null,
          actionMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ProjectProgressReportActionStatus.failure,
          action: action,
          savedReport: null,
          actionMessage: failureMessage,
        ),
      );
    }
  }

  List<ProjectProgressReport> _mergeReport(
    List<ProjectProgressReport> reports,
    ProjectProgressReport savedReport,
  ) {
    final index = reports.indexWhere((item) => item.id == savedReport.id);
    if (index < 0) {
      return List<ProjectProgressReport>.unmodifiable([
        savedReport,
        ...reports,
      ]);
    }

    final updated = List<ProjectProgressReport>.of(reports);
    updated[index] = savedReport;
    return List<ProjectProgressReport>.unmodifiable(updated);
  }

  String? _validateLoadParameters({
    required String projectObjectId,
    required String projectId,
    required String academicYearId,
  }) {
    if (projectObjectId.isEmpty) return 'Thiếu định danh đồ án.';
    if (projectId.isEmpty) return 'Thiếu mã đồ án.';
    if (academicYearId.isEmpty) return 'Thiếu năm học.';
    return null;
  }

  String? _validateRequest(ProjectProgressReportRequest request) {
    if (request.projectId.trim().isEmpty) return 'Thiếu mã đồ án.';
    if (request.academicYearId.trim().isEmpty) return 'Thiếu năm học.';
    if (request.key.trim().isEmpty) return 'Bạn phải nhập tiêu đề báo cáo.';
    if (request.brief.trim().isEmpty) return 'Bạn phải nhập nội dung báo cáo.';
    if (request.difficulty.trim().isEmpty) {
      return 'Bạn phải nhập khó khăn đang gặp phải.';
    }
    if (request.expectation.trim().isEmpty) {
      return 'Bạn phải nhập kết quả dự kiến.';
    }
    if (request.link.trim().isEmpty) {
      return 'Bạn phải nhập liên kết minh chứng.';
    }
    return null;
  }

  void _onActionStateCleared(
    ProjectProgressReportActionStateCleared event,
    Emitter<ProjectProgressReportState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: ProjectProgressReportActionStatus.initial,
        action: null,
        savedReport: null,
        actionMessage: null,
      ),
    );
  }
}

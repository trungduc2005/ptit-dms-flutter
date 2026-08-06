import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_download.dart';
import 'package:ptit_dms_flutter/domain/entities/research_post_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_post_acceptance_report_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_post_acceptance_report/bloc/research_post_acceptance_report_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/research_post_acceptance_report/widgets/research_post_acceptance_report_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/bloc/context/research_pre_acceptance_context_bloc.dart';

typedef ResearchPostAcceptanceFilePickerCallback =
    Future<ResearchPostAcceptanceUploadFile?> Function();

typedef ResearchPostAcceptanceFileSaverCallback =
    Future<bool> Function(ResearchPostAcceptanceReportDownload file);

class ResearchPostAcceptanceReportPage extends StatelessWidget {
  const ResearchPostAcceptanceReportPage({
    this.pickFile,
    this.saveFile,
    super.key,
  });

  final ResearchPostAcceptanceFilePickerCallback? pickFile;
  final ResearchPostAcceptanceFileSaverCallback? saveFile;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ResearchPreAcceptanceContextBloc(
            academicYearRepository: context.read<AcademicYearRepository>(),
            researchRepository: context.read<ResearchRepository>(),
          )..add(const ResearchPreAcceptanceContextStarted()),
        ),
        BlocProvider(
          create: (context) => ResearchPostAcceptanceReportBloc(
            repository: context.read<ResearchPostAcceptanceReportRepository>(),
          ),
        ),
      ],
      child: _ResearchPostAcceptanceReportView(
        pickFile: pickFile,
        saveFile: saveFile,
      ),
    );
  }
}

class _ResearchPostAcceptanceReportView extends StatefulWidget {
  const _ResearchPostAcceptanceReportView({
    required this.pickFile,
    required this.saveFile,
  });

  final ResearchPostAcceptanceFilePickerCallback? pickFile;
  final ResearchPostAcceptanceFileSaverCallback? saveFile;

  @override
  State<_ResearchPostAcceptanceReportView> createState() =>
      _ResearchPostAcceptanceReportViewState();
}

class _ResearchPostAcceptanceReportViewState
    extends State<_ResearchPostAcceptanceReportView> {
  final Map<ResearchPostAcceptanceFileType, ResearchPostAcceptanceUploadFile?>
  _files = {
    for (final type in ResearchPostAcceptanceFileType.values) type: null,
  };

  void _loadReports(ResearchPreAcceptanceContextState state) {
    final researchId = state.selectedResearchId?.trim();
    final yearId = state.selectedAcademicYearId?.trim();
    if (researchId == null ||
        researchId.isEmpty ||
        yearId == null ||
        yearId.isEmpty) {
      return;
    }

    context.read<ResearchPostAcceptanceReportBloc>().add(
      ResearchPostAcceptanceReportStarted(
        researchId: researchId,
        yearId: yearId,
      ),
    );
  }

  void _clearFiles() {
    if (!_files.values.any((file) => file != null)) return;
    setState(() {
      for (final type in _files.keys) {
        _files[type] = null;
      }
    });
  }

  void _selectAcademicYear(String? value) {
    final yearId = value?.trim();
    if (yearId == null || yearId.isEmpty) return;
    _clearFiles();
    context.read<ResearchPreAcceptanceContextBloc>().add(
      ResearchPreAcceptanceAcademicYearSelected(yearId),
    );
  }

  void _selectResearch(String? value) {
    final researchId = value?.trim();
    if (researchId == null || researchId.isEmpty) return;
    _clearFiles();
    context.read<ResearchPreAcceptanceContextBloc>().add(
      ResearchPreAcceptanceResearchSelected(researchId),
    );
  }

  Future<ResearchPostAcceptanceUploadFile?> _pickPlatformFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ResearchPostAcceptanceReportRequest.allowedExtensions
          .toList(),
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final selected = result.files.single;
    return ResearchPostAcceptanceUploadFile(
      fileName: selected.name,
      path: selected.path,
      bytes: selected.bytes,
      size: selected.size,
    );
  }

  Future<void> _pickFile(ResearchPostAcceptanceFileType type) async {
    try {
      final selected = await (widget.pickFile ?? _pickPlatformFile).call();
      if (!mounted || selected == null) return;

      final error = _validateFile(selected);
      if (error != null) {
        _showMessage(error, isError: true);
        return;
      }
      setState(() => _files[type] = selected);
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở trình chọn tệp.', isError: true);
      }
    }
  }

  String? _validateFile(ResearchPostAcceptanceUploadFile file) {
    final fileName = file.fileName.trim();
    final separator = fileName.lastIndexOf('.');
    if (separator <= 0 || separator == fileName.length - 1) {
      return 'Tệp đã chọn không có phần mở rộng hợp lệ.';
    }

    final extension = fileName.substring(separator + 1).toLowerCase();
    if (!ResearchPostAcceptanceReportRequest.allowedExtensions.contains(
      extension,
    )) {
      return 'Tệp phải có định dạng PDF, DOC hoặc DOCX.';
    }

    final size = file.effectiveSize;
    if (size == null || size <= 0) return 'Tệp đã chọn không có dữ liệu.';
    if (size > ResearchPostAcceptanceReportRequest.maxFileSizeInBytes) {
      return 'Tệp đã chọn vượt quá giới hạn 10 MB.';
    }

    final path = file.path?.trim();
    if (file.bytes == null && (path == null || path.isEmpty)) {
      return 'Không thể đọc dữ liệu tệp đã chọn.';
    }
    return null;
  }

  void _submit(
    ResearchPreAcceptanceContextState contextState,
    ResearchPostAcceptanceReportState reportState,
  ) {
    if (reportState.isUploading) return;

    final researchId = contextState.selectedResearchId?.trim();
    final yearId = contextState.selectedAcademicYearId?.trim();
    final report = _files[ResearchPostAcceptanceFileType.report];
    final minutes = _files[ResearchPostAcceptanceFileType.acceptanceMinutes];
    final committee =
        _files[ResearchPostAcceptanceFileType.acceptanceCommitteeList];
    final proposal = _files[ResearchPostAcceptanceFileType.proposal];
    final revision = _files[ResearchPostAcceptanceFileType.revisionExplanation];
    final decision = _files[ResearchPostAcceptanceFileType.acceptanceDecision];

    if (researchId == null ||
        researchId.isEmpty ||
        yearId == null ||
        yearId.isEmpty) {
      _showMessage(
        'Thiếu thông tin đề tài nghiên cứu hoặc năm học.',
        isError: true,
      );
      return;
    }
    if (report == null ||
        minutes == null ||
        committee == null ||
        proposal == null ||
        revision == null ||
        decision == null) {
      _showMessage('Cần chọn đầy đủ 6 tệp để nộp.', isError: true);
      return;
    }

    context.read<ResearchPostAcceptanceReportBloc>().add(
      ResearchPostAcceptanceReportUploaded(
        request: ResearchPostAcceptanceReportRequest(
          researchId: researchId,
          yearId: yearId,
          submitterType: ResearchPostAcceptanceSubmitterType.student,
          reportFile: report,
          acceptanceMinutesFile: minutes,
          acceptanceCommitteeListFile: committee,
          proposalFile: proposal,
          revisionExplanationFile: revision,
          acceptanceDecisionFile: decision,
        ),
      ),
    );
  }

  void _handleUploadState(
    BuildContext context,
    ResearchPostAcceptanceReportState state,
  ) {
    if (state.uploadStatus ==
            ResearchPostAcceptanceReportUploadStatus.initial ||
        state.uploadStatus ==
            ResearchPostAcceptanceReportUploadStatus.uploading) {
      return;
    }

    final success =
        state.uploadStatus == ResearchPostAcceptanceReportUploadStatus.success;
    _showMessage(
      state.uploadMessage ??
          (success
              ? 'Nộp báo cáo sau nghiệm thu thành công.'
              : 'Không thể nộp báo cáo sau nghiệm thu.'),
      isError: !success,
    );
    if (success) _clearFiles();

    context.read<ResearchPostAcceptanceReportBloc>().add(
      const ResearchPostAcceptanceReportUploadStateCleared(),
    );
  }

  void _download(
    ResearchPostAcceptanceReportFile file,
    ResearchPreAcceptanceContextState contextState,
  ) {
    context.read<ResearchPostAcceptanceReportBloc>().add(
      ResearchPostAcceptanceReportFileDownloaded(
        fileKey: file.fileKey,
        yearId: contextState.selectedAcademicYearId,
      ),
    );
  }

  Future<bool> _savePlatformFile(
    ResearchPostAcceptanceReportDownload file,
  ) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Lưu tệp báo cáo',
      fileName: file.fileName,
      bytes: file.bytes,
    );
    if (outputPath == null) return false;

    if (!Platform.isAndroid && !Platform.isIOS) {
      await File(outputPath).writeAsBytes(file.bytes, flush: true);
    }
    return true;
  }

  Future<void> _handleDownloadState(
    BuildContext context,
    ResearchPostAcceptanceReportState state,
  ) async {
    if (state.downloadStatus ==
            ResearchPostAcceptanceReportDownloadStatus.initial ||
        state.downloadStatus ==
            ResearchPostAcceptanceReportDownloadStatus.downloading) {
      return;
    }

    final reportBloc = context.read<ResearchPostAcceptanceReportBloc>();
    var success =
        state.downloadStatus ==
        ResearchPostAcceptanceReportDownloadStatus.success;
    var message =
        state.downloadMessage ??
        (success ? 'Tải tệp thành công.' : 'Không thể tải tệp báo cáo.');

    final downloadedFile = state.downloadedFile;
    if (success && downloadedFile != null) {
      try {
        success = await (widget.saveFile ?? _savePlatformFile)(downloadedFile);
        message = success ? 'Đã lưu tệp thành công.' : 'Đã hủy lưu tệp.';
      } catch (_) {
        success = false;
        message = 'Không thể lưu tệp báo cáo.';
      }
    }

    if (!mounted) return;

    _showMessage(message, isError: !success);
    reportBloc.add(const ResearchPostAcceptanceReportDownloadStateCleared());
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? AppTheme.brandColor
              : const Color(0xFF21835A),
        ),
      );
  }

  Future<void> _refresh() async {
    if (context.read<ResearchPostAcceptanceReportBloc>().state.isBusy) return;
    context.read<ResearchPreAcceptanceContextBloc>().add(
      const ResearchPreAcceptanceContextRefreshed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<
          ResearchPreAcceptanceContextBloc,
          ResearchPreAcceptanceContextState
        >(
          listenWhen: (previous, current) =>
              current.status == ResearchPreAcceptanceContextStatus.success &&
              (previous.status != current.status ||
                  previous.selectedAcademicYearId !=
                      current.selectedAcademicYearId ||
                  previous.selectedResearchId != current.selectedResearchId),
          listener: (_, state) => _loadReports(state),
        ),
        BlocListener<
          ResearchPostAcceptanceReportBloc,
          ResearchPostAcceptanceReportState
        >(
          listenWhen: (previous, current) =>
              previous.uploadStatus != current.uploadStatus,
          listener: _handleUploadState,
        ),
        BlocListener<
          ResearchPostAcceptanceReportBloc,
          ResearchPostAcceptanceReportState
        >(
          listenWhen: (previous, current) =>
              previous.downloadStatus != current.downloadStatus,
          listener: _handleDownloadState,
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(
          title: 'Báo cáo sau nghiệm thu',
          showBackButton: true,
        ),
        body:
            BlocBuilder<
              ResearchPreAcceptanceContextBloc,
              ResearchPreAcceptanceContextState
            >(
              builder: (context, contextState) {
                final initialLoading =
                    contextState.status ==
                        ResearchPreAcceptanceContextStatus.initial ||
                    (contextState.status ==
                            ResearchPreAcceptanceContextStatus.loading &&
                        contextState.academicYears.isEmpty);
                if (initialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      ResearchPostAcceptanceContextSection(
                        academicYears: contextState.academicYears,
                        researches: contextState.researches,
                        selectedAcademicYearId:
                            contextState.selectedAcademicYearId,
                        selectedResearchId: contextState.selectedResearchId,
                        isBusy: contextState.isLoading,
                        onAcademicYearChanged: _selectAcademicYear,
                        onResearchChanged: _selectResearch,
                      ),
                      const SizedBox(height: 16),
                      if (contextState.status ==
                          ResearchPreAcceptanceContextStatus.failure)
                        ResearchPostAcceptanceErrorState(
                          message:
                              contextState.errorMessage ??
                              'Không thể tải thông tin báo cáo sau nghiệm thu.',
                          onRetry: () => context
                              .read<ResearchPreAcceptanceContextBloc>()
                              .add(
                                const ResearchPreAcceptanceContextRefreshed(),
                              ),
                        )
                      else if (contextState.academicYears.isEmpty)
                        const ResearchPostAcceptanceEmptyState(
                          icon: Icons.calendar_month_outlined,
                          title: 'Chưa có năm học',
                          message:
                              'Chưa có năm học để nộp báo cáo sau nghiệm thu.',
                        )
                      else if (contextState.researches.isEmpty)
                        const ResearchPostAcceptanceEmptyState(
                          icon: Icons.science_outlined,
                          title: 'Chưa có đề tài nghiên cứu',
                          message:
                              'Bạn chưa có đề tài nghiên cứu trong năm học này.',
                        )
                      else
                        BlocBuilder<
                          ResearchPostAcceptanceReportBloc,
                          ResearchPostAcceptanceReportState
                        >(
                          builder: (_, reportState) =>
                              _buildReportContent(contextState, reportState),
                        ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildReportContent(
    ResearchPreAcceptanceContextState contextState,
    ResearchPostAcceptanceReportState state,
  ) {
    if (state.loadStatus == ResearchPostAcceptanceReportLoadStatus.initial ||
        state.loadStatus == ResearchPostAcceptanceReportLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 38),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadStatus == ResearchPostAcceptanceReportLoadStatus.failure) {
      return ResearchPostAcceptanceErrorState(
        message:
            state.loadErrorMessage ?? 'Không thể tải báo cáo sau nghiệm thu.',
        onRetry: () => context.read<ResearchPostAcceptanceReportBloc>().add(
          const ResearchPostAcceptanceReportRefreshed(),
        ),
      );
    }

    final reports = [...state.reports]
      ..sort((first, second) => second.order.compareTo(first.order));
    final latestReport = reports.firstOrNull;

    return Column(
      children: [
        if (latestReport != null) ...[
          ResearchPostAcceptanceStatusSection(report: latestReport),
          const SizedBox(height: 16),
        ],
        ResearchPostAcceptanceUploadSection(
          files: _files,
          enabled:
              !state.isBusy &&
              contextState.status == ResearchPreAcceptanceContextStatus.success,
          isUploading: state.isUploading,
          uploadProgress: state.uploadProgress,
          isResubmission: latestReport != null,
          onPick: _pickFile,
          onRemove: (type) => setState(() => _files[type] = null),
          onSubmit: () => _submit(contextState, state),
        ),
        if (reports.isEmpty) ...[
          const SizedBox(height: 16),
          const ResearchPostAcceptanceEmptyState(
            icon: Icons.upload_file_outlined,
            title: 'Chưa có báo cáo sau nghiệm thu',
            message: 'Chọn đầy đủ 6 tệp ở trên để thực hiện lần nộp đầu tiên.',
          ),
        ] else ...[
          const SizedBox(height: 16),
          ResearchPostAcceptanceHistorySection(
            reports: reports,
            downloadingFileKey: state.downloadingFileKey,
            onDownloadFile: (file) => _download(file, contextState),
          ),
        ],
      ],
    );
  }
}

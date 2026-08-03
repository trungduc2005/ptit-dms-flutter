import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report.dart';
import 'package:ptit_dms_flutter/domain/entities/research_pre_acceptance_report_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_pre_acceptance_report_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/bloc/context/research_pre_acceptance_context_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/bloc/research_pre_acceptance_report_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/widgets/research_pre_acceptance_report_sections.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ResearchPreAcceptanceFilePickerCallback =
    Future<ResearchPreAcceptanceUploadFile?> Function();

class ResearchPreAcceptanceReportPage extends StatelessWidget {
  const ResearchPreAcceptanceReportPage({
    this.pickFile,
    this.openFile,
    super.key,
  });

  final ResearchPreAcceptanceFilePickerCallback? pickFile;
  final Future<bool> Function(Uri uri)? openFile;

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
          create: (context) => ResearchPreAcceptanceReportBloc(
            repository: context.read<ResearchPreAcceptanceReportRepository>(),
          ),
        ),
      ],
      child: _ResearchPreAcceptanceReportView(
        pickFile: pickFile,
        openFile: openFile,
      ),
    );
  }
}

class _ResearchPreAcceptanceReportView extends StatefulWidget {
  const _ResearchPreAcceptanceReportView({
    required this.pickFile,
    required this.openFile,
  });

  final ResearchPreAcceptanceFilePickerCallback? pickFile;
  final Future<bool> Function(Uri uri)? openFile;

  @override
  State<_ResearchPreAcceptanceReportView> createState() =>
      _ResearchPreAcceptanceReportViewState();
}

class _ResearchPreAcceptanceReportViewState
    extends State<_ResearchPreAcceptanceReportView> {
  ResearchPreAcceptanceUploadFile? _reportFile;
  ResearchPreAcceptanceUploadFile? _turnitinReportFile;

  void _loadReports(ResearchPreAcceptanceContextState state) {
    final researchId = state.selectedResearchId?.trim();
    final yearId = state.selectedAcademicYearId?.trim();
    if (researchId == null ||
        researchId.isEmpty ||
        yearId == null ||
        yearId.isEmpty) {
      return;
    }

    context.read<ResearchPreAcceptanceReportBloc>().add(
      ResearchPreAcceptanceReportStarted(
        researchId: researchId,
        yearId: yearId,
      ),
    );
  }

  void _clearSelectedFiles() {
    if (_reportFile == null && _turnitinReportFile == null) return;
    setState(() {
      _reportFile = null;
      _turnitinReportFile = null;
    });
  }

  void _selectAcademicYear(String? value) {
    final yearId = value?.trim();
    if (yearId == null || yearId.isEmpty) return;
    _clearSelectedFiles();
    context.read<ResearchPreAcceptanceContextBloc>().add(
      ResearchPreAcceptanceAcademicYearSelected(yearId),
    );
  }

  void _selectResearch(String? value) {
    final researchId = value?.trim();
    if (researchId == null || researchId.isEmpty) return;
    _clearSelectedFiles();
    context.read<ResearchPreAcceptanceContextBloc>().add(
      ResearchPreAcceptanceResearchSelected(researchId),
    );
  }

  Future<ResearchPreAcceptanceUploadFile?> _pickPlatformFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ResearchPreAcceptanceReportRequest.allowedExtensions
          .toList(),
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final selected = result.files.single;
    return ResearchPreAcceptanceUploadFile(
      fileName: selected.name,
      path: selected.path,
      bytes: selected.bytes,
      size: selected.size,
    );
  }

  Future<void> _pickFile({required bool isReport}) async {
    try {
      final selected = await (widget.pickFile ?? _pickPlatformFile).call();
      if (!mounted || selected == null) return;

      final validationError = _validateSelectedFile(selected);
      if (validationError != null) {
        _showMessage(validationError, isError: true);
        return;
      }

      setState(() {
        if (isReport) {
          _reportFile = selected;
        } else {
          _turnitinReportFile = selected;
        }
      });
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở trình chọn tệp.', isError: true);
      }
    }
  }

  String? _validateSelectedFile(ResearchPreAcceptanceUploadFile file) {
    final fileName = file.fileName.trim();
    final separator = fileName.lastIndexOf('.');
    if (separator <= 0 || separator == fileName.length - 1) {
      return 'Tệp đã chọn không có phần mở rộng hợp lệ.';
    }

    final extension = fileName.substring(separator + 1).toLowerCase();
    if (!ResearchPreAcceptanceReportRequest.allowedExtensions.contains(
      extension,
    )) {
      return 'Tệp phải có định dạng PDF, DOC hoặc DOCX.';
    }

    final size = file.effectiveSize;
    if (size == null || size <= 0) {
      return 'Tệp đã chọn không có dữ liệu.';
    }
    if (size > ResearchPreAcceptanceReportRequest.maxFileSizeInBytes) {
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
    ResearchPreAcceptanceReportState reportState,
  ) {
    if (reportState.isUploading) return;

    final researchId = contextState.selectedResearchId?.trim();
    final yearId = contextState.selectedAcademicYearId?.trim();
    final reportFile = _reportFile;
    final turnitinFile = _turnitinReportFile;
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
    if (reportFile == null || turnitinFile == null) {
      _showMessage('Cần chọn đủ cả hai tệp để nộp.', isError: true);
      return;
    }

    context.read<ResearchPreAcceptanceReportBloc>().add(
      ResearchPreAcceptanceReportUploaded(
        request: ResearchPreAcceptanceReportRequest(
          researchId: researchId,
          yearId: yearId,
          reportFile: reportFile,
          turnitinReportFile: turnitinFile,
        ),
      ),
    );
  }

  void _handleUploadState(
    BuildContext context,
    ResearchPreAcceptanceReportState state,
  ) {
    if (state.uploadStatus == ResearchPreAcceptanceReportUploadStatus.initial ||
        state.uploadStatus ==
            ResearchPreAcceptanceReportUploadStatus.uploading) {
      return;
    }

    final success =
        state.uploadStatus == ResearchPreAcceptanceReportUploadStatus.success;
    _showMessage(
      state.uploadMessage ??
          (success
              ? 'Nộp báo cáo trước nghiệm thu thành công.'
              : 'Không thể nộp báo cáo trước nghiệm thu.'),
      isError: !success,
    );

    if (success) {
      _clearSelectedFiles();
    }

    context.read<ResearchPreAcceptanceReportBloc>().add(
      const ResearchPreAcceptanceReportUploadStateCleared(),
    );
  }

  Future<void> _openFile(String value) async {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !const {'http', 'https'}.contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty) {
      _showMessage('Đường dẫn tệp không hợp lệ.', isError: true);
      return;
    }

    try {
      final opened = widget.openFile != null
          ? await widget.openFile!(uri)
          : await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Không thể mở tệp báo cáo.', isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở tệp báo cáo.', isError: true);
      }
    }
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
    final reportState = context.read<ResearchPreAcceptanceReportBloc>().state;
    if (reportState.isUploading) return;

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
          ResearchPreAcceptanceReportBloc,
          ResearchPreAcceptanceReportState
        >(
          listenWhen: (previous, current) =>
              previous.uploadStatus != current.uploadStatus,
          listener: _handleUploadState,
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(
          title: 'Báo cáo trước nghiệm thu',
          showBackButton: true,
        ),
        body:
            BlocBuilder<
              ResearchPreAcceptanceContextBloc,
              ResearchPreAcceptanceContextState
            >(
              builder: (context, contextState) {
                final isInitialLoading =
                    contextState.status ==
                        ResearchPreAcceptanceContextStatus.initial ||
                    (contextState.status ==
                            ResearchPreAcceptanceContextStatus.loading &&
                        contextState.academicYears.isEmpty);

                if (isInitialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      ResearchPreAcceptanceContextSection(
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
                        ResearchPreAcceptanceErrorState(
                          message:
                              contextState.errorMessage ??
                              'Không thể tải thông tin báo cáo trước nghiệm thu.',
                          onRetry: () => context
                              .read<ResearchPreAcceptanceContextBloc>()
                              .add(
                                const ResearchPreAcceptanceContextRefreshed(),
                              ),
                        )
                      else if (contextState.academicYears.isEmpty)
                        const ResearchPreAcceptanceEmptyState(
                          icon: Icons.calendar_month_outlined,
                          title: 'Chưa có năm học',
                          message:
                              'Chưa có năm học để nộp báo cáo trước nghiệm thu.',
                        )
                      else if (contextState.researches.isEmpty)
                        const ResearchPreAcceptanceEmptyState(
                          icon: Icons.science_outlined,
                          title: 'Chưa có đề tài nghiên cứu',
                          message:
                              'Bạn chưa có đề tài nghiên cứu trong năm học này nên chưa thể nộp báo cáo trước nghiệm thu.',
                        )
                      else
                        BlocBuilder<
                          ResearchPreAcceptanceReportBloc,
                          ResearchPreAcceptanceReportState
                        >(
                          builder: (context, reportState) =>
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
    ResearchPreAcceptanceReportState state,
  ) {
    if (state.loadStatus == ResearchPreAcceptanceReportLoadStatus.initial ||
        state.loadStatus == ResearchPreAcceptanceReportLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 38),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadStatus == ResearchPreAcceptanceReportLoadStatus.failure) {
      return ResearchPreAcceptanceErrorState(
        message:
            state.loadErrorMessage ?? 'Không thể tải báo cáo trước nghiệm thu.',
        onRetry: () => context.read<ResearchPreAcceptanceReportBloc>().add(
          const ResearchPreAcceptanceReportRefreshed(),
        ),
      );
    }

    final reports = [...state.reports]
      ..sort((first, second) => second.order.compareTo(first.order));
    final latestReport = reports.firstOrNull;
    final canSubmit =
        latestReport == null ||
        latestReport.status == ResearchPreAcceptanceReportStatus.rejected;
    final isResubmission = latestReport != null;

    return Column(
      children: [
        if (latestReport != null) ...[
          ResearchPreAcceptanceStatusSection(report: latestReport),
          const SizedBox(height: 16),
        ],
        if (canSubmit)
          ResearchPreAcceptanceUploadSection(
            reportFile: _reportFile,
            turnitinReportFile: _turnitinReportFile,
            enabled:
                !state.isBusy &&
                contextState.status ==
                    ResearchPreAcceptanceContextStatus.success,
            isUploading: state.isUploading,
            uploadProgress: state.uploadProgress,
            isResubmission: isResubmission,
            onPickReport: () => _pickFile(isReport: true),
            onPickTurnitin: () => _pickFile(isReport: false),
            onRemoveReport: () => setState(() => _reportFile = null),
            onRemoveTurnitin: () => setState(() => _turnitinReportFile = null),
            onSubmit: () => _submit(contextState, state),
          ),
        if (reports.isEmpty) ...[
          const SizedBox(height: 16),
          const ResearchPreAcceptanceEmptyState(
            icon: Icons.upload_file_outlined,
            title: 'Chưa có báo cáo trước nghiệm thu',
            message: 'Chọn đủ hai tệp ở trên để thực hiện lần nộp đầu tiên.',
          ),
        ] else ...[
          const SizedBox(height: 16),
          ResearchPreAcceptanceHistorySection(
            reports: reports,
            onOpenFile: _openFile,
          ),
        ],
      ],
    );
  }
}

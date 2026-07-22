import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_post_defense_submission_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_post_defense_submission/bloc/project_post_defense_submission_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_post_defense_submission/widgets/project_post_defense_submission_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';

class ProjectPostDefenseSubmissionPage extends StatelessWidget {
  const ProjectPostDefenseSubmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProjectRegistrationContextBloc(
            studentProfileRepository: context.read<StudentProfileRepository>(),
            academicYearRepository: context.read<AcademicYearRepository>(),
            projectRepository: context.read<ProjectRepository>(),
            timelineRepository: context.read<TimelineRepository>(),
          )..add(const ProjectRegistrationContextStarted()),
        ),
        BlocProvider(
          create: (context) => ProjectPostDefenseSubmissionBloc(
            repository: context.read<ProjectPostDefenseSubmissionRepository>(),
          ),
        ),
      ],
      child: const _ProjectPostDefenseSubmissionView(),
    );
  }
}

enum _PostDefenseFileType { thesis, responseCommittee, approvalMinutes, source }

class _ProjectPostDefenseSubmissionView extends StatefulWidget {
  const _ProjectPostDefenseSubmissionView();

  @override
  State<_ProjectPostDefenseSubmissionView> createState() =>
      _ProjectPostDefenseSubmissionViewState();
}

class _ProjectPostDefenseSubmissionViewState
    extends State<_ProjectPostDefenseSubmissionView> {
  ProjectPostDefenseUploadFile? _thesisFile;
  ProjectPostDefenseUploadFile? _responseCommitteeFile;
  ProjectPostDefenseUploadFile? _approvalMinutesFile;
  ProjectPostDefenseUploadFile? _sourceFile;

  void _loadSubmission(ProjectRegistrationContextState state) {
    final project = state.existingProject;
    final academicYearId = state.selectedAcademicYearId?.trim();
    if (project == null || academicYearId == null || academicYearId.isEmpty) {
      return;
    }

    context.read<ProjectPostDefenseSubmissionBloc>().add(
      ProjectPostDefenseSubmissionStarted(
        projectId: project.projectId,
        academicYearId: academicYearId,
      ),
    );
  }

  void _selectAcademicYear(String? value) {
    if (value == null || value.trim().isEmpty) return;
    _clearSelectedFiles();
    context.read<ProjectRegistrationContextBloc>().add(
      ProjectRegistrationAcademicYearSelected(value),
    );
  }

  Future<void> _pickFile(_PostDefenseFileType fileType) async {
    final isSource = fileType == _PostDefenseFileType.source;
    final allowedExtensions = isSource
        ? ProjectPostDefenseSubmissionRequest.sourceExtensions
        : ProjectPostDefenseSubmissionRequest.documentExtensions;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions.toList(growable: false),
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final selected = result.files.single;
      if (selected.size <= 0) {
        _showMessage('Tệp đã chọn không có dữ liệu.', isError: true);
        return;
      }
      if (selected.size >
          ProjectPostDefenseSubmissionRequest.maxFileSizeInBytes) {
        _showMessage('Tệp đã chọn vượt quá giới hạn 25 MB.', isError: true);
        return;
      }
      if (selected.path == null && selected.bytes == null) {
        _showMessage('Không thể đọc dữ liệu tệp đã chọn.', isError: true);
        return;
      }

      final uploadFile = ProjectPostDefenseUploadFile(
        fileName: selected.name,
        path: selected.path,
        bytes: selected.bytes,
        size: selected.size,
      );

      setState(() {
        switch (fileType) {
          case _PostDefenseFileType.thesis:
            _thesisFile = uploadFile;
          case _PostDefenseFileType.responseCommittee:
            _responseCommitteeFile = uploadFile;
          case _PostDefenseFileType.approvalMinutes:
            _approvalMinutesFile = uploadFile;
          case _PostDefenseFileType.source:
            _sourceFile = uploadFile;
        }
      });
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở trình chọn tệp.', isError: true);
      }
    }
  }

  void _removeFile(_PostDefenseFileType fileType) {
    setState(() {
      switch (fileType) {
        case _PostDefenseFileType.thesis:
          _thesisFile = null;
        case _PostDefenseFileType.responseCommittee:
          _responseCommitteeFile = null;
        case _PostDefenseFileType.approvalMinutes:
          _approvalMinutesFile = null;
        case _PostDefenseFileType.source:
          _sourceFile = null;
      }
    });
  }

  void _clearSelectedFiles() {
    setState(() {
      _thesisFile = null;
      _responseCommitteeFile = null;
      _approvalMinutesFile = null;
      _sourceFile = null;
    });
  }

  void _submit(
    ProjectRegistrationContextState contextState,
    ProjectPostDefenseSubmissionState submissionState,
  ) {
    if (submissionState.isUploading) return;

    final project = contextState.existingProject;
    final academicYearId = contextState.selectedAcademicYearId?.trim();
    if (project == null || academicYearId == null || academicYearId.isEmpty) {
      _showMessage('Thiếu thông tin đồ án hoặc năm học.', isError: true);
      return;
    }

    final thesisFile = _thesisFile;
    final responseCommitteeFile = _responseCommitteeFile;
    final approvalMinutesFile = _approvalMinutesFile;
    final sourceFile = _sourceFile;
    if (thesisFile == null ||
        responseCommitteeFile == null ||
        approvalMinutesFile == null ||
        sourceFile == null) {
      _showMessage('Cần chọn đầy đủ 4 tệp trước khi nộp.', isError: true);
      return;
    }

    context.read<ProjectPostDefenseSubmissionBloc>().add(
      ProjectPostDefenseSubmissionUploaded(
        request: ProjectPostDefenseSubmissionRequest(
          projectId: project.projectId,
          academicYearId: academicYearId,
          thesisFile: thesisFile,
          responseCommitteeFile: responseCommitteeFile,
          approvalMinutesFile: approvalMinutesFile,
          sourceFile: sourceFile,
        ),
      ),
    );
  }

  void _handleUploadState(
    BuildContext context,
    ProjectPostDefenseSubmissionState state,
  ) {
    if (state.uploadStatus ==
            ProjectPostDefenseSubmissionUploadStatus.initial ||
        state.uploadStatus ==
            ProjectPostDefenseSubmissionUploadStatus.uploading) {
      return;
    }

    final success =
        state.uploadStatus == ProjectPostDefenseSubmissionUploadStatus.success;
    _showMessage(
      state.uploadMessage ??
          (success
              ? 'Nộp đồ án sau bảo vệ thành công.'
              : 'Không thể nộp đồ án sau bảo vệ.'),
      isError: !success,
    );

    if (success) {
      _clearSelectedFiles();
    }

    context.read<ProjectPostDefenseSubmissionBloc>().add(
      const ProjectPostDefenseSubmissionUploadStateCleared(),
    );
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
    context.read<ProjectRegistrationContextBloc>().add(
      const ProjectRegistrationContextRefreshed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<
          ProjectRegistrationContextBloc,
          ProjectRegistrationContextState
        >(
          listenWhen: (previous, current) =>
              current.status == ProjectRegistrationContextStatus.success &&
              (previous.status != current.status ||
                  previous.selectedAcademicYearId !=
                      current.selectedAcademicYearId ||
                  previous.existingProject?.id != current.existingProject?.id),
          listener: (_, state) => _loadSubmission(state),
        ),
        BlocListener<
          ProjectPostDefenseSubmissionBloc,
          ProjectPostDefenseSubmissionState
        >(
          listenWhen: (previous, current) =>
              previous.uploadStatus != current.uploadStatus,
          listener: _handleUploadState,
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(
          title: 'Nộp báo cáo sau bảo vệ',
          showBackButton: true,
        ),
        body:
            BlocBuilder<
              ProjectRegistrationContextBloc,
              ProjectRegistrationContextState
            >(
              builder: (context, contextState) {
                final isInitialLoading =
                    contextState.status ==
                        ProjectRegistrationContextStatus.initial ||
                    (contextState.status ==
                            ProjectRegistrationContextStatus.loading &&
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
                      if (contextState.status ==
                          ProjectRegistrationContextStatus.loading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: LinearProgressIndicator(),
                        ),
                      ProjectPostDefenseContextSection(
                        academicYears: contextState.academicYears,
                        selectedAcademicYearId:
                            contextState.selectedAcademicYearId,
                        isBusy:
                            contextState.status ==
                            ProjectRegistrationContextStatus.loading,
                        onChanged: _selectAcademicYear,
                      ),
                      const SizedBox(height: 16),
                      if (contextState.status ==
                          ProjectRegistrationContextStatus.failure)
                        ProjectPostDefenseErrorState(
                          message:
                              contextState.errorMessage ??
                              'Không thể tải thông tin đồ án.',
                          onRetry: () => context
                              .read<ProjectRegistrationContextBloc>()
                              .add(const ProjectRegistrationContextRefreshed()),
                        )
                      else if (contextState.existingProject == null)
                        const ProjectPostDefenseEmptyState(
                          icon: Icons.assignment_late_outlined,
                          title: 'Chưa có đồ án',
                          message:
                              'Bạn chưa có đồ án trong năm học này nên chưa thể nộp báo cáo sau bảo vệ.',
                        )
                      else
                        BlocBuilder<
                          ProjectPostDefenseSubmissionBloc,
                          ProjectPostDefenseSubmissionState
                        >(
                          builder: (context, submissionState) =>
                              _buildSubmissionContent(
                                contextState,
                                submissionState,
                              ),
                        ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildSubmissionContent(
    ProjectRegistrationContextState contextState,
    ProjectPostDefenseSubmissionState state,
  ) {
    if (state.loadStatus == ProjectPostDefenseSubmissionLoadStatus.initial ||
        state.loadStatus == ProjectPostDefenseSubmissionLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 38),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadStatus == ProjectPostDefenseSubmissionLoadStatus.failure) {
      return ProjectPostDefenseErrorState(
        message:
            state.loadErrorMessage ??
            'Không thể tải thông tin nộp báo cáo sau bảo vệ.',
        onRetry: () => context.read<ProjectPostDefenseSubmissionBloc>().add(
          const ProjectPostDefenseSubmissionRefreshed(),
        ),
      );
    }

    final submission = state.submission;
    if (submission == null) {
      return ProjectPostDefenseErrorState(
        message: 'Dữ liệu nộp báo cáo sau bảo vệ không hợp lệ.',
        onRetry: () => context.read<ProjectPostDefenseSubmissionBloc>().add(
          const ProjectPostDefenseSubmissionRefreshed(),
        ),
      );
    }

    return Column(
      children: [
        if (submission.hasSubmitted) ...[
          ProjectPostDefenseStatusSection(submission: submission),
          const SizedBox(height: 16),
        ],
        if (state.canUpload)
          ProjectPostDefenseUploadSection(
            thesisFile: _thesisFile,
            responseCommitteeFile: _responseCommitteeFile,
            approvalMinutesFile: _approvalMinutesFile,
            sourceFile: _sourceFile,
            enabled:
                !state.isBusy &&
                contextState.status == ProjectRegistrationContextStatus.success,
            isUploading: state.isUploading,
            uploadProgress: state.uploadProgress,
            onPickThesis: () => _pickFile(_PostDefenseFileType.thesis),
            onPickResponseCommittee: () =>
                _pickFile(_PostDefenseFileType.responseCommittee),
            onPickApprovalMinutes: () =>
                _pickFile(_PostDefenseFileType.approvalMinutes),
            onPickSource: () => _pickFile(_PostDefenseFileType.source),
            onRemoveThesis: () => _removeFile(_PostDefenseFileType.thesis),
            onRemoveResponseCommittee: () =>
                _removeFile(_PostDefenseFileType.responseCommittee),
            onRemoveApprovalMinutes: () =>
                _removeFile(_PostDefenseFileType.approvalMinutes),
            onRemoveSource: () => _removeFile(_PostDefenseFileType.source),
            onSubmit: () => _submit(contextState, state),
            isResubmission: submission.hasSubmitted,
          )
        else
          const ProjectPostDefenseEmptyState(
            icon: Icons.lock_outline,
            title: 'Hồ sơ đã được duyệt',
            message:
                'Hồ sơ đã được giảng viên hướng dẫn và hội đồng phê duyệt, bạn không cần nộp lại.',
          ),
        if (submission.submissions.isNotEmpty) ...[
          const SizedBox(height: 16),
          ProjectPostDefenseHistorySection(attempts: submission.submissions),
        ],
      ],
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_pre_defense_submission_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_pre_defense_submission/bloc/project_pre_defense_submission_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_pre_defense_submission/widgets/project_pre_defense_submission_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';

class ProjectPreDefenseSubmissionPage extends StatelessWidget {
  const ProjectPreDefenseSubmissionPage({super.key});

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
          create: (context) => ProjectPreDefenseSubmissionBloc(
            repository: context.read<ProjectPreDefenseSubmissionRepository>(),
          ),
        ),
      ],
      child: const _ProjectPreDefenseSubmissionView(),
    );
  }
}

class _ProjectPreDefenseSubmissionView extends StatefulWidget {
  const _ProjectPreDefenseSubmissionView();

  @override
  State<_ProjectPreDefenseSubmissionView> createState() =>
      _ProjectPreDefenseSubmissionViewState();
}

class _ProjectPreDefenseSubmissionViewState
    extends State<_ProjectPreDefenseSubmissionView> {
  ProjectPreDefenseUploadFile? _thesisFile;
  ProjectPreDefenseUploadFile? _turnitinFile;

  void _loadSubmission(ProjectRegistrationContextState state) {
    final project = state.existingProject;
    final academicYearId = state.selectedAcademicYearId?.trim();
    if (project == null || academicYearId == null || academicYearId.isEmpty) {
      return;
    }

    context.read<ProjectPreDefenseSubmissionBloc>().add(
      ProjectPreDefenseSubmissionStarted(
        projectId: project.projectId,
        academicYearId: academicYearId,
      ),
    );
  }

  void _selectAcademicYear(String? value) {
    if (value == null || value.trim().isEmpty) return;
    setState(() {
      _thesisFile = null;
      _turnitinFile = null;
    });
    context.read<ProjectRegistrationContextBloc>().add(
      ProjectRegistrationAcademicYearSelected(value),
    );
  }

  Future<void> _pickFile({required bool isThesis}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ProjectPreDefenseSubmissionRequest.allowedExtensions
            .toList(),
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
          ProjectPreDefenseSubmissionRequest.maxFileSizeInBytes) {
        _showMessage('Tệp đã chọn vượt quá giới hạn 25 MB.', isError: true);
        return;
      }
      if (selected.path == null && selected.bytes == null) {
        _showMessage('Không thể đọc dữ liệu tệp đã chọn.', isError: true);
        return;
      }

      final uploadFile = ProjectPreDefenseUploadFile(
        fileName: selected.name,
        path: selected.path,
        bytes: selected.bytes,
        size: selected.size,
      );

      setState(() {
        if (isThesis) {
          _thesisFile = uploadFile;
        } else {
          _turnitinFile = uploadFile;
        }
      });
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể mở trình chọn tệp.', isError: true);
      }
    }
  }

  void _submit(
    ProjectRegistrationContextState contextState,
    ProjectPreDefenseSubmissionState submissionState,
  ) {
    if (submissionState.isUploading) return;

    final project = contextState.existingProject;
    final academicYearId = contextState.selectedAcademicYearId?.trim();
    if (project == null || academicYearId == null || academicYearId.isEmpty) {
      _showMessage('Thiếu thông tin đồ án hoặc năm học.', isError: true);
      return;
    }
    if (_thesisFile == null && _turnitinFile == null) {
      _showMessage('Cần chọn ít nhất một tệp để nộp.', isError: true);
      return;
    }

    context.read<ProjectPreDefenseSubmissionBloc>().add(
      ProjectPreDefenseSubmissionUploaded(
        request: ProjectPreDefenseSubmissionRequest(
          projectId: project.projectId,
          academicYearId: academicYearId,
          thesisFile: _thesisFile,
          turnitinReportFile: _turnitinFile,
        ),
      ),
    );
  }

  void _handleUploadState(
    BuildContext context,
    ProjectPreDefenseSubmissionState state,
  ) {
    if (state.uploadStatus == ProjectPreDefenseSubmissionUploadStatus.initial ||
        state.uploadStatus ==
            ProjectPreDefenseSubmissionUploadStatus.uploading) {
      return;
    }

    final success =
        state.uploadStatus == ProjectPreDefenseSubmissionUploadStatus.success;
    _showMessage(
      state.uploadMessage ??
          (success
              ? 'Nộp đồ án trước bảo vệ thành công.'
              : 'Không thể nộp đồ án trước bảo vệ.'),
      isError: !success,
    );

    if (success) {
      setState(() {
        _thesisFile = null;
        _turnitinFile = null;
      });
    }

    context.read<ProjectPreDefenseSubmissionBloc>().add(
      const ProjectPreDefenseSubmissionUploadStateCleared(),
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
          ProjectPreDefenseSubmissionBloc,
          ProjectPreDefenseSubmissionState
        >(
          listenWhen: (previous, current) =>
              previous.uploadStatus != current.uploadStatus,
          listener: _handleUploadState,
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(
          title: 'Nộp báo cáo trước bảo vệ',
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
                      ProjectPreDefenseContextSection(
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
                        ProjectPreDefenseErrorState(
                          message:
                              contextState.errorMessage ??
                              'Không thể tải thông tin đồ án.',
                          onRetry: () => context
                              .read<ProjectRegistrationContextBloc>()
                              .add(const ProjectRegistrationContextRefreshed()),
                        )
                      else if (contextState.existingProject == null)
                        const ProjectPreDefenseEmptyState(
                          icon: Icons.assignment_late_outlined,
                          title: 'Chưa có đồ án',
                          message:
                              'Bạn chưa có đồ án trong năm học này nên chưa thể nộp báo cáo trước bảo vệ.',
                        )
                      else
                        BlocBuilder<
                          ProjectPreDefenseSubmissionBloc,
                          ProjectPreDefenseSubmissionState
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
    ProjectPreDefenseSubmissionState state,
  ) {
    if (state.loadStatus == ProjectPreDefenseSubmissionLoadStatus.initial ||
        state.loadStatus == ProjectPreDefenseSubmissionLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 38),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadStatus == ProjectPreDefenseSubmissionLoadStatus.failure) {
      return ProjectPreDefenseErrorState(
        message:
            state.loadErrorMessage ??
            'Không thể tải thông tin nộp báo cáo trước bảo vệ.',
        onRetry: () => context.read<ProjectPreDefenseSubmissionBloc>().add(
          const ProjectPreDefenseSubmissionRefreshed(),
        ),
      );
    }

    final submission = state.submission;
    if (submission == null) {
      return ProjectPreDefenseErrorState(
        message: 'Dữ liệu nộp báo cáo trước bảo vệ không hợp lệ.',
        onRetry: () => context.read<ProjectPreDefenseSubmissionBloc>().add(
          const ProjectPreDefenseSubmissionRefreshed(),
        ),
      );
    }

    final canUpload = state.canUpload;
    return Column(
      children: [
        if (submission.hasSubmitted) ...[
          ProjectPreDefenseStatusSection(submission: submission),
          const SizedBox(height: 16),
        ],
        if (canUpload)
          ProjectPreDefenseUploadSection(
            thesisFile: _thesisFile,
            turnitinFile: _turnitinFile,
            enabled:
                !state.isBusy &&
                contextState.status == ProjectRegistrationContextStatus.success,
            isUploading: state.isUploading,
            uploadProgress: state.uploadProgress,
            onPickThesis: () => _pickFile(isThesis: true),
            onPickTurnitin: () => _pickFile(isThesis: false),
            onRemoveThesis: () => setState(() => _thesisFile = null),
            onRemoveTurnitin: () => setState(() => _turnitinFile = null),
            onSubmit: () => _submit(contextState, state),
            isResubmission: submission.hasSubmitted,
          )
        else
          const ProjectPreDefenseEmptyState(
            icon: Icons.lock_outline,
            title: 'Hồ sơ đã được duyệt',
            message:
                'Bạn không cần nộp lại khi hồ sơ đã được giảng viên hướng dẫn phê duyệt.',
          ),
        if (submission.submissions.isNotEmpty) ...[
          const SizedBox(height: 16),
          ProjectPreDefenseHistorySection(attempts: submission.submissions),
        ],
      ],
    );
  }
}

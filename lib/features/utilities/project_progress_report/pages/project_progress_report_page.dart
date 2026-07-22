import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/theme/theme.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_progress_report_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_progress_report/bloc/project_progress_report_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_progress_report/widgets/project_progress_report_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';

class ProjectProgressReportPage extends StatelessWidget {
  const ProjectProgressReportPage({super.key});

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
          create: (context) => ProjectProgressReportBloc(
            repository: context.read<ProjectProgressReportRepository>(),
          ),
        ),
      ],
      child: const _ProjectProgressReportView(),
    );
  }
}

class _ProjectProgressReportView extends StatefulWidget {
  const _ProjectProgressReportView();

  @override
  State<_ProjectProgressReportView> createState() =>
      _ProjectProgressReportViewState();
}

class _ProjectProgressReportViewState
    extends State<_ProjectProgressReportView> {
  final _briefController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _expectationController = TextEditingController();
  final _linkController = TextEditingController();

  ProjectProgressReportTab _selectedTab = ProjectProgressReportTab.reports;
  ProjectProgressReport? _editingReport;
  List<Timeline> _reportPeriods = const [];
  String? _selectedReportPeriodKey;
  bool _isLoadingReportPeriods = false;
  String? _reportPeriodError;
  int _periodLoadGeneration = 0;

  @override
  void dispose() {
    _periodLoadGeneration++;
    _briefController.dispose();
    _difficultyController.dispose();
    _expectationController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadReports(ProjectRegistrationContextState state) async {
    final project = state.existingProject;
    final academicYearId = state.selectedAcademicYearId;
    if (project == null || academicYearId == null) return;

    final generation = ++_periodLoadGeneration;
    setState(() {
      _isLoadingReportPeriods = true;
      _reportPeriodError = null;
      _reportPeriods = const [];
      _selectedReportPeriodKey = null;
    });

    try {
      final timelines = await context
          .read<TimelineRepository>()
          .getProjectTimelines(academicYearId: academicYearId);
      if (!mounted || generation != _periodLoadGeneration) return;

      final reportPeriods =
          timelines
              .where(
                (item) =>
                    item.type == 'projectReport' &&
                    item.key?.trim().isNotEmpty == true,
              )
              .toList(growable: false)
            ..sort((a, b) {
              final aStart = a.startTime;
              final bStart = b.startTime;
              if (aStart == null && bStart == null) return 0;
              if (aStart == null) return 1;
              if (bStart == null) return -1;
              return aStart.compareTo(bStart);
            });

      setState(() {
        _reportPeriods = reportPeriods;
        _selectedReportPeriodKey = reportPeriods.isEmpty
            ? null
            : reportPeriods.first.key!.trim();
        _isLoadingReportPeriods = false;
      });
    } catch (_) {
      if (!mounted || generation != _periodLoadGeneration) return;
      setState(() {
        _isLoadingReportPeriods = false;
        _reportPeriodError = 'Không thể tải danh sách đợt báo cáo.';
      });
    }

    if (!mounted || generation != _periodLoadGeneration) return;
    context.read<ProjectProgressReportBloc>().add(
      ProjectProgressReportStarted(
        projectObjectId: project.id,
        projectId: project.projectId,
        academicYearId: academicYearId,
      ),
    );
  }

  void _selectAcademicYear(String? value) {
    if (value == null || value.isEmpty) return;
    _cancelEditing();
    context.read<ProjectRegistrationContextBloc>().add(
      ProjectRegistrationAcademicYearSelected(value),
    );
  }

  void _selectReportPeriod(String? value) {
    if (value == null || value.trim().isEmpty) return;
    _cancelEditing();
    setState(() => _selectedReportPeriodKey = value);
  }

  void _edit(ProjectProgressReport report) {
    setState(() {
      _editingReport = report;
      _selectedTab = ProjectProgressReportTab.reports;
      _selectedReportPeriodKey = report.key;
      _briefController.text = report.brief;
      _difficultyController.text = report.difficulty;
      _expectationController.text = report.expectation;
      _linkController.text = report.link;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PrimaryScrollController.maybeOf(context)?.animateTo(
          250,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingReport = null;
      _briefController.clear();
      _difficultyController.clear();
      _expectationController.clear();
      _linkController.clear();
    });
  }

  void _submit(
    ProjectRegistrationContextState contextState,
    ProjectProgressReportState reportState,
  ) {
    final project = contextState.existingProject;
    final academicYearId = contextState.selectedAcademicYearId;
    final reportPeriodKey = _selectedReportPeriodKey?.trim();
    if (project == null || academicYearId == null) return;
    if (reportPeriodKey == null || reportPeriodKey.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Bạn phải chọn đợt báo cáo.')),
        );
      return;
    }

    final request = ProjectProgressReportRequest(
      projectId: project.projectId,
      key: reportPeriodKey,
      brief: _briefController.text.trim(),
      difficulty: _difficultyController.text.trim(),
      expectation: _expectationController.text.trim(),
      link: _linkController.text.trim(),
      academicYearId: academicYearId,
    );

    final bloc = context.read<ProjectProgressReportBloc>();
    if (_editingReport == null) {
      bloc.add(ProjectProgressReportCreated(request: request));
    } else {
      bloc.add(ProjectProgressReportUpdated(request: request));
    }
  }

  void _handleReportAction(
    BuildContext context,
    ProjectProgressReportState state,
  ) {
    if (state.actionStatus == ProjectProgressReportActionStatus.initial ||
        state.actionStatus == ProjectProgressReportActionStatus.loading) {
      return;
    }

    final success =
        state.actionStatus == ProjectProgressReportActionStatus.success;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.actionMessage ?? ''),
          backgroundColor: success
              ? const Color(0xFF21835A)
              : AppTheme.brandColor,
        ),
      );

    if (success) _cancelEditing();
    context.read<ProjectProgressReportBloc>().add(
      const ProjectProgressReportActionStateCleared(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      ProjectRegistrationContextBloc,
      ProjectRegistrationContextState
    >(
      listenWhen: (previous, current) =>
          current.status == ProjectRegistrationContextStatus.success &&
          (previous.status != current.status ||
              previous.selectedAcademicYearId !=
                  current.selectedAcademicYearId ||
              previous.existingProject?.id != current.existingProject?.id),
      listener: (_, state) => _loadReports(state),
      child: BlocListener<ProjectProgressReportBloc, ProjectProgressReportState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: _handleReportAction,
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          appBar: const AppHeader(
            title: 'Báo cáo tiến độ',
            showBackButton: true,
          ),
          body:
              BlocBuilder<
                ProjectRegistrationContextBloc,
                ProjectRegistrationContextState
              >(
                builder: (context, contextState) {
                  if (contextState.status ==
                          ProjectRegistrationContextStatus.initial ||
                      (contextState.status ==
                              ProjectRegistrationContextStatus.loading &&
                          contextState.academicYears.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProjectRegistrationContextBloc>().add(
                        const ProjectRegistrationContextRefreshed(),
                      );
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        ProjectProgressReportContextSection(
                          academicYearItems: contextState.academicYears,
                          selectedAcademicYearId:
                              contextState.selectedAcademicYearId,
                          isAcademicYearBusy:
                              contextState.status ==
                              ProjectRegistrationContextStatus.loading,
                          onAcademicYearChanged: _selectAcademicYear,
                          reportPeriodItems: _reportPeriods,
                          selectedReportPeriodKey: _selectedReportPeriodKey,
                          isReportPeriodBusy: _isLoadingReportPeriods,
                          reportPeriodErrorMessage: _reportPeriodError,
                          reportPeriodEnabled:
                              contextState.existingProject != null,
                          onReportPeriodChanged: _selectReportPeriod,
                          onReportPeriodRetry: () => _loadReports(contextState),
                        ),
                        const SizedBox(height: 16),
                        if (contextState.status ==
                            ProjectRegistrationContextStatus.failure)
                          ProjectProgressReportErrorState(
                            message:
                                contextState.errorMessage ??
                                'Không thể tải thông tin đồ án.',
                            onRetry: () => context
                                .read<ProjectRegistrationContextBloc>()
                                .add(
                                  const ProjectRegistrationContextRefreshed(),
                                ),
                          )
                        else if (contextState.existingProject == null)
                          const ProjectProgressReportEmptyState(
                            icon: Icons.assignment_late_outlined,
                            title: 'Chưa có đồ án',
                            message:
                                'Bạn chưa có đồ án trong năm học này nên chưa thể gửi báo cáo tiến độ.',
                          )
                        else ...[
                          BlocBuilder<
                            ProjectProgressReportBloc,
                            ProjectProgressReportState
                          >(
                            builder: (context, reportState) {
                              final hasReportForSelectedPeriod =
                                  _selectedReportPeriodKey != null &&
                                  reportState.reports.any(
                                    (report) =>
                                        report.key == _selectedReportPeriodKey,
                                  );
                              final canShowCreateForm =
                                  reportState.loadStatus ==
                                      ProjectProgressReportLoadStatus.success &&
                                  _selectedReportPeriodKey != null &&
                                  !hasReportForSelectedPeriod;
                              final showForm =
                                  _editingReport != null || canShowCreateForm;

                              return Column(
                                children: [
                                  if (showForm) ...[
                                    ProjectProgressReportForm(
                                      briefController: _briefController,
                                      difficultyController:
                                          _difficultyController,
                                      expectationController:
                                          _expectationController,
                                      linkController: _linkController,
                                      isEditing: _editingReport != null,
                                      isSubmitting: reportState.isSubmitting,
                                      onSubmit: () =>
                                          _submit(contextState, reportState),
                                      onCancel: _cancelEditing,
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                  if (_editingReport == null) ...[
                                    ProjectProgressReportTabSwitcher(
                                      selectedTab: _selectedTab,
                                      reportCount: reportState.reports.length,
                                      replyCount: reportState.replies.length,
                                      onChanged: (value) =>
                                          setState(() => _selectedTab = value),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildReportContent(reportState),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildReportContent(ProjectProgressReportState state) {
    final selectedKey = _selectedReportPeriodKey;
    final reports = selectedKey == null
        ? const <ProjectProgressReport>[]
        : state.reports
              .where((report) => report.key == selectedKey)
              .toList(growable: false);
    final replies = selectedKey == null
        ? const <ProjectReportReply>[]
        : state.replies
              .where((reply) => reply.key == selectedKey)
              .toList(growable: false);

    if (state.loadStatus == ProjectProgressReportLoadStatus.initial ||
        state.loadStatus == ProjectProgressReportLoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(),
      );
    }

    if (state.loadStatus == ProjectProgressReportLoadStatus.failure) {
      return ProjectProgressReportErrorState(
        message: state.loadErrorMessage ?? 'Không thể tải báo cáo tiến độ.',
        onRetry: () => context.read<ProjectProgressReportBloc>().add(
          const ProjectProgressReportRefreshed(),
        ),
      );
    }

    if (_selectedTab == ProjectProgressReportTab.reports) {
      if (reports.isEmpty) {
        return const ProjectProgressReportEmptyState(
          title: 'Chưa có báo cáo',
          message: 'Báo cáo đầu tiên của bạn sẽ xuất hiện tại đây.',
        );
      }

      return Column(
        children: [
          for (var index = 0; index < reports.length; index++) ...[
            ProjectProgressReportCard(
              report: reports[index],
              index: index,
              onEdit: () => _edit(reports[index]),
            ),
            if (index < reports.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    if (replies.isEmpty) {
      return const ProjectProgressReportEmptyState(
        icon: Icons.forum_outlined,
        title: 'Chưa có phản hồi',
        message: 'Phản hồi của giảng viên hướng dẫn sẽ xuất hiện tại đây.',
      );
    }

    final lecturerName =
        context
            .read<ProjectRegistrationContextBloc>()
            .state
            .existingProject
            ?.guider
            ?.lecturerName ??
        '';

    return Column(
      children: [
        for (var index = 0; index < replies.length; index++) ...[
          ProjectReportReplyCard(
            reply: replies[index],
            lecturerName: lecturerName,
          ),
          if (index < replies.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_result_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_result/bloc/project_result_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_result/widgets/project_result_sections.dart';

class ProjectResultPage extends StatelessWidget {
  const ProjectResultPage({super.key});

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
          create: (context) =>
              ProjectResultBloc(context.read<ProjectResultRepository>()),
        ),
      ],
      child: const _ProjectResultView(),
    );
  }
}

class _ProjectResultView extends StatelessWidget {
  const _ProjectResultView();

  void _loadResultForCurrentProject(
    BuildContext context,
    ProjectRegistrationContextState state,
  ) {
    final projectId = state.existingProject?.projectId.trim() ?? '';
    final academicYearId = state.selectedAcademicYearId?.trim() ?? '';
    if (projectId.isEmpty || academicYearId.isEmpty) return;

    context.read<ProjectResultBloc>().add(
      ProjectResultStarted(
        projectId: projectId,
        academicYearId: academicYearId,
      ),
    );
  }

  void _selectAcademicYear(BuildContext context, String? academicYearId) {
    if (academicYearId == null || academicYearId.trim().isEmpty) return;

    context.read<ProjectRegistrationContextBloc>().add(
      ProjectRegistrationAcademicYearSelected(academicYearId),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<ProjectRegistrationContextBloc>().add(
      const ProjectRegistrationContextRefreshed(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
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
              previous.existingProject?.projectId !=
                  current.existingProject?.projectId),
      listener: _loadResultForCurrentProject,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(
          title: 'Kết quả đồ án tốt nghiệp',
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
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      ProjectResultAcademicYearSection(
                        academicYears: contextState.academicYears,
                        selectedAcademicYearId:
                            contextState.selectedAcademicYearId,
                        isLoading:
                            contextState.status ==
                            ProjectRegistrationContextStatus.loading,
                        onChanged: (value) =>
                            _selectAcademicYear(context, value),
                      ),
                      const SizedBox(height: 16),
                      if (contextState.status ==
                          ProjectRegistrationContextStatus.failure)
                        ProjectResultErrorState(
                          message:
                              contextState.errorMessage ??
                              'Không thể tải thông tin đồ án.',
                          onRetry: () => context
                              .read<ProjectRegistrationContextBloc>()
                              .add(const ProjectRegistrationContextRefreshed()),
                        )
                      else if (contextState.existingProject == null)
                        const ProjectResultNoProjectState()
                      else
                        BlocBuilder<ProjectResultBloc, ProjectResultState>(
                          builder: (context, resultState) {
                            switch (resultState.status) {
                              case ProjectResultStatus.initial:
                              case ProjectResultStatus.loading:
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              case ProjectResultStatus.failure:
                                return ProjectResultErrorState(
                                  message:
                                      resultState.errorMessage ??
                                      'Không thể tải kết quả đồ án.',
                                  onRetry: () => context
                                      .read<ProjectResultBloc>()
                                      .add(const ProjectResultRefreshed()),
                                );
                              case ProjectResultStatus.success:
                                final result = resultState.result;
                                if (result == null || !result.isPublished) {
                                  return const ProjectResultEmptyState();
                                }
                                return ProjectResultOverviewSection(
                                  result: result,
                                );
                            }
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}

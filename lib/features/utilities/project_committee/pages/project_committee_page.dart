import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_committee_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/project_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/project_committee/bloc/project_committee_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/project_committee/widgets/project_committee_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/project_registration/bloc/context/project_registration_context_bloc.dart';

class ProjectCommitteePage extends StatelessWidget {
  const ProjectCommitteePage({super.key});

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
              ProjectCommitteeBloc(context.read<ProjectCommitteeRepository>()),
        ),
      ],
      child: const _ProjectCommitteeView(),
    );
  }
}

class _ProjectCommitteeView extends StatelessWidget {
  const _ProjectCommitteeView();

  void _loadCommittee(BuildContext context, String academicYearId) {
    if (academicYearId.trim().isEmpty) return;
    context.read<ProjectCommitteeBloc>().add(
      ProjectCommitteeStarted(academicYearId: academicYearId),
    );
  }

  void _selectAcademicYear(BuildContext context, String? academicYearId) {
    if (academicYearId == null || academicYearId.trim().isEmpty) return;
    context.read<ProjectRegistrationContextBloc>().add(
      ProjectRegistrationAcademicYearSelected(academicYearId),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final contextBloc = context.read<ProjectRegistrationContextBloc>();
    final academicYearId = contextBloc.state.selectedAcademicYearId;
    contextBloc.add(const ProjectRegistrationContextRefreshed());

    if (academicYearId != null && academicYearId.trim().isNotEmpty) {
      context.read<ProjectCommitteeBloc>().add(
        const ProjectCommitteeRefreshed(),
      );
    }

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
          current.selectedAcademicYearId != null &&
          (previous.status != current.status ||
              previous.selectedAcademicYearId !=
                  current.selectedAcademicYearId),
      listener: (context, state) {
        _loadCommittee(context, state.selectedAcademicYearId!);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(title: 'Phân hội đồng', showBackButton: true),
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
                      ProjectCommitteeAcademicYearSection(
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
                        ProjectCommitteeErrorState(
                          message:
                              contextState.errorMessage ??
                              'Không thể tải danh sách năm học.',
                          onRetry: () => context
                              .read<ProjectRegistrationContextBloc>()
                              .add(const ProjectRegistrationContextRefreshed()),
                        )
                      else
                        BlocBuilder<
                          ProjectCommitteeBloc,
                          ProjectCommitteeState
                        >(
                          builder: (context, committeeState) {
                            switch (committeeState.status) {
                              case ProjectCommitteeStatus.initial:
                              case ProjectCommitteeStatus.loading:
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              case ProjectCommitteeStatus.failure:
                                return ProjectCommitteeErrorState(
                                  message:
                                      committeeState.errorMessage ??
                                      'Không thể tải thông tin phân hội đồng.',
                                  onRetry: () => context
                                      .read<ProjectCommitteeBloc>()
                                      .add(const ProjectCommitteeRefreshed()),
                                );
                              case ProjectCommitteeStatus.success:
                                final committee = committeeState.committee;
                                if (committee == null) {
                                  return const ProjectCommitteeEmptyState();
                                }
                                return ProjectCommitteeOverviewSection(
                                  committee: committee,
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

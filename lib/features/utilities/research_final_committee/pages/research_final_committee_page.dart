import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_final_committee_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_final_committee/bloc/research_final_committee_bloc.dart';
import 'package:ptit_dms_flutter/features/utilities/research_final_committee/widgets/research_final_committee_sections.dart';
import 'package:ptit_dms_flutter/features/utilities/research_pre_acceptance_report/bloc/context/research_pre_acceptance_context_bloc.dart';

class ResearchFinalCommitteePage extends StatelessWidget {
  const ResearchFinalCommitteePage({super.key});

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
          create: (context) => ResearchFinalCommitteeBloc(
            repository: context.read<ResearchFinalCommitteeRepository>(),
          ),
        ),
      ],
      child: const _ResearchFinalCommitteeView(),
    );
  }
}

class _ResearchFinalCommitteeView extends StatelessWidget {
  const _ResearchFinalCommitteeView();

  void _loadCommittee(
    BuildContext context,
    ResearchPreAcceptanceContextState state,
  ) {
    final yearId = state.selectedAcademicYearId?.trim();
    if (yearId == null || yearId.isEmpty) return;

    context.read<ResearchFinalCommitteeBloc>().add(
      ResearchFinalCommitteeStarted(yearId: yearId),
    );
  }

  void _selectAcademicYear(BuildContext context, String? value) {
    final yearId = value?.trim();
    if (yearId == null || yearId.isEmpty) return;

    context.read<ResearchPreAcceptanceContextBloc>().add(
      ResearchPreAcceptanceAcademicYearSelected(yearId),
    );
  }

  void _selectResearch(BuildContext context, String? value) {
    final researchId = value?.trim();
    if (researchId == null || researchId.isEmpty) return;

    context.read<ResearchFinalCommitteeBloc>().add(
      ResearchFinalCommitteeResearchSelected(researchId),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final contextBloc = context.read<ResearchPreAcceptanceContextBloc>();
    final committeeBloc = context.read<ResearchFinalCommitteeBloc>();

    contextBloc.add(const ResearchPreAcceptanceContextRefreshed());
    if (committeeBloc.state.yearId.isNotEmpty) {
      committeeBloc.add(const ResearchFinalCommitteeRefreshed());
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      ResearchPreAcceptanceContextBloc,
      ResearchPreAcceptanceContextState
    >(
      listenWhen: (previous, current) =>
          current.status == ResearchPreAcceptanceContextStatus.success &&
          current.selectedAcademicYearId != null &&
          (previous.status != current.status ||
              previous.selectedAcademicYearId !=
                  current.selectedAcademicYearId),
      listener: _loadCommittee,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: const AppHeader(
          title: 'Hội đồng nghiệm thu',
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

                return BlocBuilder<
                  ResearchFinalCommitteeBloc,
                  ResearchFinalCommitteeState
                >(
                  builder: (context, committeeState) {
                    return RefreshIndicator(
                      onRefresh: () => _refresh(context),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        children: [
                          ResearchFinalCommitteeFilterSection(
                            academicYears: contextState.academicYears,
                            researches: committeeState.researches,
                            selectedAcademicYearId:
                                contextState.selectedAcademicYearId,
                            selectedResearchId:
                                committeeState.selectedResearchId,
                            isYearLoading: contextState.isLoading,
                            isCommitteeLoading: committeeState.isLoading,
                            onAcademicYearChanged: (value) =>
                                _selectAcademicYear(context, value),
                            onResearchChanged: (value) =>
                                _selectResearch(context, value),
                          ),
                          const SizedBox(height: 16),
                          _buildContent(
                            context,
                            contextState: contextState,
                            committeeState: committeeState,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required ResearchPreAcceptanceContextState contextState,
    required ResearchFinalCommitteeState committeeState,
  }) {
    if (contextState.status == ResearchPreAcceptanceContextStatus.failure) {
      return ResearchFinalCommitteeErrorState(
        message:
            contextState.errorMessage ?? 'Không thể tải danh sách năm học.',
        onRetry: () => context.read<ResearchPreAcceptanceContextBloc>().add(
          const ResearchPreAcceptanceContextRefreshed(),
        ),
      );
    }

    if (contextState.academicYears.isEmpty) {
      return const ResearchFinalCommitteeEmptyState(
        icon: Icons.calendar_month_outlined,
        title: 'Chưa có năm học',
        message: 'Chưa có năm học để xem thông tin hội đồng nghiệm thu.',
      );
    }

    switch (committeeState.status) {
      case ResearchFinalCommitteeStatus.initial:
      case ResearchFinalCommitteeStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        );
      case ResearchFinalCommitteeStatus.failure:
        return ResearchFinalCommitteeErrorState(
          message:
              committeeState.errorMessage ??
              'Không thể tải thông tin hội đồng nghiệm thu.',
          onRetry: () => context.read<ResearchFinalCommitteeBloc>().add(
            const ResearchFinalCommitteeRefreshed(),
          ),
        );
      case ResearchFinalCommitteeStatus.success:
        if (committeeState.researches.isEmpty) {
          return const ResearchFinalCommitteeEmptyState(
            icon: Icons.science_outlined,
            title: 'Chưa có đề tài nghiệm thu',
            message:
                'Bạn chưa có đề tài nghiên cứu được xếp nghiệm thu trong năm học này.',
          );
        }

        final committee = committeeState.committee;
        if (committee == null) {
          return const ResearchFinalCommitteeEmptyState(
            title: 'Chưa được phân hội đồng',
            message:
                'Thông tin hội đồng nghiệm thu của đề tài chưa được công bố.',
          );
        }

        return ResearchFinalCommitteeOverviewSection(committee: committee);
    }
  }
}

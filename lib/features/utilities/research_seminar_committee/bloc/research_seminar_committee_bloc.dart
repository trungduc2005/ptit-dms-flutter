import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_seminar_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_seminar_committee_repository.dart';

import 'research_seminar_committee_event.dart';
import 'research_seminar_committee_state.dart';

export 'research_seminar_committee_event.dart';
export 'research_seminar_committee_state.dart';

class ResearchSeminarCommitteeBloc
    extends Bloc<ResearchSeminarCommitteeEvent, ResearchSeminarCommitteeState> {
  ResearchSeminarCommitteeBloc({
    required ResearchSeminarCommitteeRepository repository,
  }) : _repository = repository,
       super(const ResearchSeminarCommitteeState()) {
    on<ResearchSeminarCommitteeStarted>(_onStarted);
    on<ResearchSeminarCommitteeRefreshed>(_onRefreshed);
    on<ResearchSeminarCommitteeResearchSelected>(_onResearchSelected);
  }

  final ResearchSeminarCommitteeRepository _repository;

  Future<void> _onStarted(
    ResearchSeminarCommitteeStarted event,
    Emitter<ResearchSeminarCommitteeState> emit,
  ) async {
    final yearId = event.yearId.trim();
    final researchId = _normalizeOptionalIdentifier(event.researchId);

    if (yearId.isEmpty) {
      emit(
        state.copyWith(
          status: ResearchSeminarCommitteeStatus.failure,
          yearId: '',
          researches: const [],
          selectedResearchId: null,
          committee: null,
          errorMessage: 'Thiếu thông tin năm học của hội đồng hội thảo.',
        ),
      );
      return;
    }

    await _load(
      emit,
      yearId: yearId,
      researchId: researchId,
      clearData: yearId != state.yearId,
    );
  }

  Future<void> _onRefreshed(
    ResearchSeminarCommitteeRefreshed event,
    Emitter<ResearchSeminarCommitteeState> emit,
  ) async {
    if (state.yearId.isEmpty) return;

    await _load(
      emit,
      yearId: state.yearId,
      researchId: state.selectedResearchId,
      clearData: false,
    );
  }

  Future<void> _onResearchSelected(
    ResearchSeminarCommitteeResearchSelected event,
    Emitter<ResearchSeminarCommitteeState> emit,
  ) async {
    final researchId = event.researchId.trim();
    final isAvailable = state.researches.any(
      (research) => research.researchId == researchId,
    );

    if (researchId.isEmpty || !isAvailable || state.yearId.isEmpty) {
      return;
    }
    if (researchId == state.selectedResearchId &&
        state.status == ResearchSeminarCommitteeStatus.success) {
      return;
    }

    await _load(
      emit,
      yearId: state.yearId,
      researchId: researchId,
      clearData: false,
    );
  }

  Future<void> _load(
    Emitter<ResearchSeminarCommitteeState> emit, {
    required String yearId,
    required String? researchId,
    required bool clearData,
  }) async {
    emit(
      state.copyWith(
        status: ResearchSeminarCommitteeStatus.loading,
        yearId: yearId,
        researches: clearData ? const [] : state.researches,
        selectedResearchId: researchId,
        committee: clearData ? null : state.committee,
        errorMessage: null,
      ),
    );

    try {
      final result = await _repository.getMyCommittee(
        yearId: yearId,
        researchId: researchId,
      );
      if (emit.isDone || isClosed) return;

      var researches = List<ResearchSeminarOption>.unmodifiable(
        result.researches,
      );
      var committee = result.committee;
      final selectedResearchId = _resolveSelectedResearchId(
        researches: researches,
        committee: committee,
        requestedResearchId: researchId,
      );

      // The first request for a year may only return the available researches.
      // Once a research is selected automatically, load its committee explicitly.
      if (researchId == null &&
          committee == null &&
          selectedResearchId != null) {
        final selectedResult = await _repository.getMyCommittee(
          yearId: yearId,
          researchId: selectedResearchId,
        );
        if (emit.isDone || isClosed) return;

        committee = selectedResult.committee;
        if (selectedResult.researches.isNotEmpty) {
          researches = List<ResearchSeminarOption>.unmodifiable(
            selectedResult.researches,
          );
        }
      }

      emit(
        state.copyWith(
          status: ResearchSeminarCommitteeStatus.success,
          yearId: yearId,
          researches: researches,
          selectedResearchId: selectedResearchId,
          committee: committee,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ResearchSeminarCommitteeStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ResearchSeminarCommitteeStatus.failure,
          errorMessage: 'Không thể tải thông tin hội đồng hội thảo.',
        ),
      );
    }
  }

  String? _resolveSelectedResearchId({
    required List<ResearchSeminarOption> researches,
    required ResearchSeminarCommittee? committee,
    required String? requestedResearchId,
  }) {
    final requested = _findResearchId(researches, requestedResearchId);
    if (requested != null) return requested;

    final committeeResearch = _findResearchId(
      researches,
      committee?.research.researchId,
    );
    if (committeeResearch != null) return committeeResearch;

    return researches.firstOrNull?.researchId;
  }

  String? _findResearchId(
    List<ResearchSeminarOption> researches,
    String? researchId,
  ) {
    final normalized = _normalizeOptionalIdentifier(researchId);
    if (normalized == null) return null;

    for (final research in researches) {
      if (research.researchId == normalized) return normalized;
    }
    return null;
  }

  String? _normalizeOptionalIdentifier(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

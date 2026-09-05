import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_final_committee_repository.dart';

import 'research_final_committee_event.dart';
import 'research_final_committee_state.dart';

export 'research_final_committee_event.dart';
export 'research_final_committee_state.dart';

class ResearchFinalCommitteeBloc
    extends Bloc<ResearchFinalCommitteeEvent, ResearchFinalCommitteeState> {
  ResearchFinalCommitteeBloc({
    required ResearchFinalCommitteeRepository repository,
  }) : _repository = repository,
       super(const ResearchFinalCommitteeState()) {
    on<ResearchFinalCommitteeStarted>(_onStarted);
    on<ResearchFinalCommitteeRefreshed>(_onRefreshed);
    on<ResearchFinalCommitteeResearchSelected>(_onResearchSelected);
  }

  final ResearchFinalCommitteeRepository _repository;

  Future<void> _onStarted(
    ResearchFinalCommitteeStarted event,
    Emitter<ResearchFinalCommitteeState> emit,
  ) async {
    final yearId = event.yearId.trim();
    final researchId = _normalizeOptionalIdentifier(event.researchId);

    if (yearId.isEmpty) {
      emit(
        state.copyWith(
          status: ResearchFinalCommitteeStatus.failure,
          yearId: '',
          researches: const [],
          selectedResearchId: null,
          committee: null,
          errorMessage: 'Thiếu thông tin năm học của hội đồng nghiệm thu.',
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
    ResearchFinalCommitteeRefreshed event,
    Emitter<ResearchFinalCommitteeState> emit,
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
    ResearchFinalCommitteeResearchSelected event,
    Emitter<ResearchFinalCommitteeState> emit,
  ) async {
    final researchId = event.researchId.trim();
    final isAvailable = state.researches.any(
      (research) => research.researchId == researchId,
    );

    if (researchId.isEmpty || !isAvailable || state.yearId.isEmpty) {
      return;
    }
    if (researchId == state.selectedResearchId &&
        state.status == ResearchFinalCommitteeStatus.success) {
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
    Emitter<ResearchFinalCommitteeState> emit, {
    required String yearId,
    required String? researchId,
    required bool clearData,
  }) async {
    emit(
      state.copyWith(
        status: ResearchFinalCommitteeStatus.loading,
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

      var researches = List<ResearchFinalOption>.unmodifiable(
        result.researches,
      );
      var committee = result.committee;
      final selectedResearchId = _resolveSelectedResearchId(
        researches: researches,
        committee: committee,
        requestedResearchId: researchId,
      );

      // Yêu cầu đầu tiên theo năm có thể chỉ trả về danh sách đề tài.
      // Khi tự động chọn được đề tài, tải rõ ràng hội đồng của đề tài đó.
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
          researches = List<ResearchFinalOption>.unmodifiable(
            selectedResult.researches,
          );
        }
      }

      emit(
        state.copyWith(
          status: ResearchFinalCommitteeStatus.success,
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
          status: ResearchFinalCommitteeStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ResearchFinalCommitteeStatus.failure,
          errorMessage: 'Không thể tải thông tin hội đồng nghiệm thu.',
        ),
      );
    }
  }

  String? _resolveSelectedResearchId({
    required List<ResearchFinalOption> researches,
    required ResearchFinalCommittee? committee,
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
    List<ResearchFinalOption> researches,
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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';

import 'research_pre_acceptance_context_event.dart';
import 'research_pre_acceptance_context_state.dart';

export 'research_pre_acceptance_context_event.dart';
export 'research_pre_acceptance_context_state.dart';

class ResearchPreAcceptanceContextBloc
    extends
        Bloc<
          ResearchPreAcceptanceContextEvent,
          ResearchPreAcceptanceContextState
        > {
  ResearchPreAcceptanceContextBloc({
    required AcademicYearRepository academicYearRepository,
    required ResearchRepository researchRepository,
  }) : _academicYearRepository = academicYearRepository,
       _researchRepository = researchRepository,
       super(const ResearchPreAcceptanceContextState()) {
    on<ResearchPreAcceptanceContextStarted>(_onStarted);
    on<ResearchPreAcceptanceContextRefreshed>(_onRefreshed);
    on<ResearchPreAcceptanceAcademicYearSelected>(_onAcademicYearSelected);
    on<ResearchPreAcceptanceResearchSelected>(_onResearchSelected);
  }

  final AcademicYearRepository _academicYearRepository;
  final ResearchRepository _researchRepository;

  int _generation = 0;

  Future<void> _onStarted(
    ResearchPreAcceptanceContextStarted event,
    Emitter<ResearchPreAcceptanceContextState> emit,
  ) async {
    final generation = ++_generation;
    emit(
      state.copyWith(
        status: ResearchPreAcceptanceContextStatus.loading,
        academicYears: const [],
        researches: const [],
        selectedAcademicYearId: null,
        selectedResearchId: null,
        errorMessage: null,
      ),
    );

    try {
      final academicYears = await _academicYearRepository.getAcademicYears();
      if (!_canEmit(emit, generation)) return;

      if (academicYears.isEmpty) {
        emit(
          state.copyWith(
            status: ResearchPreAcceptanceContextStatus.success,
            academicYears: const [],
            researches: const [],
            selectedAcademicYearId: null,
            selectedResearchId: null,
            errorMessage: null,
          ),
        );
        return;
      }

      final selectedYearId = academicYears.first.id.trim();
      if (selectedYearId.isEmpty) {
        emit(
          state.copyWith(
            status: ResearchPreAcceptanceContextStatus.failure,
            academicYears: List.unmodifiable(academicYears),
            researches: const [],
            selectedAcademicYearId: null,
            selectedResearchId: null,
            errorMessage: 'Năm học không hợp lệ.',
          ),
        );
        return;
      }

      final researches = await _loadResearches(selectedYearId);
      if (!_canEmit(emit, generation)) return;

      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.success,
          academicYears: List.unmodifiable(academicYears),
          researches: List.unmodifiable(researches),
          selectedAcademicYearId: selectedYearId,
          selectedResearchId: researches.firstOrNull?.researchId,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (!_canEmit(emit, generation)) return;
      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      if (!_canEmit(emit, generation)) return;
      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.failure,
          errorMessage: 'Không thể tải thông tin báo cáo trước nghiệm thu.',
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    ResearchPreAcceptanceContextRefreshed event,
    Emitter<ResearchPreAcceptanceContextState> emit,
  ) async {
    if (state.academicYears.isEmpty || state.selectedAcademicYearId == null) {
      await _onStarted(const ResearchPreAcceptanceContextStarted(), emit);
      return;
    }

    await _loadYear(
      emit,
      yearId: state.selectedAcademicYearId!,
      preferredResearchId: state.selectedResearchId,
    );
  }

  Future<void> _onAcademicYearSelected(
    ResearchPreAcceptanceAcademicYearSelected event,
    Emitter<ResearchPreAcceptanceContextState> emit,
  ) async {
    final yearId = event.academicYearId.trim();
    final exists = state.academicYears.any((year) => year.id == yearId);
    if (yearId.isEmpty || !exists) {
      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.failure,
          researches: const [],
          selectedAcademicYearId: yearId.isEmpty ? null : yearId,
          selectedResearchId: null,
          errorMessage: 'Năm học không hợp lệ.',
        ),
      );
      return;
    }

    await _loadYear(emit, yearId: yearId);
  }

  void _onResearchSelected(
    ResearchPreAcceptanceResearchSelected event,
    Emitter<ResearchPreAcceptanceContextState> emit,
  ) {
    final researchId = event.researchId.trim();
    final exists = state.researches.any(
      (research) => research.researchId == researchId,
    );
    if (researchId.isEmpty || !exists) return;

    emit(state.copyWith(selectedResearchId: researchId));
  }

  Future<void> _loadYear(
    Emitter<ResearchPreAcceptanceContextState> emit, {
    required String yearId,
    String? preferredResearchId,
  }) async {
    final generation = ++_generation;
    emit(
      state.copyWith(
        status: ResearchPreAcceptanceContextStatus.loading,
        researches: const [],
        selectedAcademicYearId: yearId,
        selectedResearchId: null,
        errorMessage: null,
      ),
    );

    try {
      final researches = await _loadResearches(yearId);
      if (!_canEmit(emit, generation)) return;

      final selectedResearchId = _selectResearchId(
        researches,
        preferredResearchId,
      );
      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.success,
          researches: List.unmodifiable(researches),
          selectedAcademicYearId: yearId,
          selectedResearchId: selectedResearchId,
          errorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (!_canEmit(emit, generation)) return;
      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      if (!_canEmit(emit, generation)) return;
      emit(
        state.copyWith(
          status: ResearchPreAcceptanceContextStatus.failure,
          errorMessage: 'Không thể tải danh sách đề tài nghiên cứu.',
        ),
      );
    }
  }

  Future<List<Research>> _loadResearches(String yearId) async {
    final researches = await _researchRepository.getUserResearches(
      yearId: yearId,
      type: 'student',
    );
    return researches
        .where((research) => research.researchId.trim().isNotEmpty)
        .toList(growable: false);
  }

  String? _selectResearchId(
    List<Research> researches,
    String? preferredResearchId,
  ) {
    final preferred = preferredResearchId?.trim();
    if (preferred != null &&
        preferred.isNotEmpty &&
        researches.any((research) => research.researchId == preferred)) {
      return preferred;
    }
    return researches.firstOrNull?.researchId;
  }

  bool _canEmit(
    Emitter<ResearchPreAcceptanceContextState> emit,
    int generation,
  ) {
    return generation == _generation && !emit.isDone && !isClosed;
  }
}

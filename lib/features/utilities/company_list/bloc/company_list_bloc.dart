import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';

import 'company_list_event.dart';
import 'company_list_state.dart';

export 'company_list_event.dart';
export 'company_list_state.dart';

class CompanyListBloc extends Bloc<CompanyListEvent, CompanyListState> {
  CompanyListBloc(this._companyRepository, this._academicYearRepository)
    : super(const CompanyListState()) {
    on<CompanyListStarted>(_onStarted);
    on<CompanyListRefreshed>(_onRefreshed);
    on<CompanyListAcademicYearChanged>(_onAcademicYearChanged);
  }

  final CompanyRepository _companyRepository;
  final AcademicYearRepository _academicYearRepository;

  Future<void> _onStarted(
    CompanyListStarted event,
    Emitter<CompanyListState> emit,
  ) async {
    emit(state.copyWith(status: CompanyListStatus.loading, errorMessage: null));

    try {
      final academicYears = await _academicYearRepository
          .getInternAcademicYears();

      if (emit.isDone || isClosed) return;

      if (academicYears.isEmpty) {
        emit(
          state.copyWith(
            status: CompanyListStatus.success,
            companies: const [],
            academicYears: const [],
            selectedAcademicYear: null,
            errorMessage: null,
          ),
        );
        return;
      }

      final selectedAcademicYear = academicYears.first;
      await _loadCompaniesForYear(
        emit,
        academicYears: academicYears,
        selectedAcademicYear: selectedAcademicYear,
        emitLoading: false,
      );
    } on AppException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: CompanyListStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    CompanyListRefreshed event,
    Emitter<CompanyListState> emit,
  ) async {
    final selectedAcademicYear = state.selectedAcademicYear;
    if (selectedAcademicYear == null) {
      await _onStarted(const CompanyListStarted(), emit);
      return;
    }

    await _loadCompaniesForYear(
      emit,
      academicYears: state.academicYears,
      selectedAcademicYear: selectedAcademicYear,
    );
  }

  Future<void> _onAcademicYearChanged(
    CompanyListAcademicYearChanged event,
    Emitter<CompanyListState> emit,
  ) async {
    if (event.academicYear == state.selectedAcademicYear) return;

    await _loadCompaniesForYear(
      emit,
      academicYears: state.academicYears,
      selectedAcademicYear: event.academicYear,
    );
  }

  Future<void> _loadCompaniesForYear(
    Emitter<CompanyListState> emit, {
    required List<AcademicYearOption> academicYears,
    required AcademicYearOption selectedAcademicYear,
    bool emitLoading = true,
  }) async {
    if (emitLoading) {
      emit(
        state.copyWith(
          status: CompanyListStatus.loading,
          companies: const [],
          academicYears: academicYears,
          selectedAcademicYear: selectedAcademicYear,
          errorMessage: null,
        ),
      );
    }

    try {
      final companies = await _companyRepository.getCompanies(
        academicYearCode: selectedAcademicYear.code,
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: CompanyListStatus.success,
          companies: companies,
          academicYears: academicYears,
          selectedAcademicYear: selectedAcademicYear,
          errorMessage: null,
        ),
      );
    } on AppException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: CompanyListStatus.failure,
          companies: const [],
          academicYears: academicYears,
          selectedAcademicYear: selectedAcademicYear,
          errorMessage: e.message,
        ),
      );
    }
  }
}

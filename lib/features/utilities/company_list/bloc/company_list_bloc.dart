import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';

import 'company_list_event.dart';
import 'company_list_state.dart';

export 'company_list_event.dart';
export 'company_list_state.dart';

class CompanyListBloc extends Bloc<CompanyListEvent, CompanyListState> {
  CompanyListBloc(this._companyRepository) : super(const CompanyListState()) {
    on<CompanyListStarted>(_onStarted);
    on<CompanyListRefreshed>(_onRefreshed);
  }

  final CompanyRepository _companyRepository;

  Future<void> _onStarted(
    CompanyListStarted event,
    Emitter<CompanyListState> emit,
  ) async {
    await _loadCompanies(emit);
  }

  Future<void> _onRefreshed(
    CompanyListRefreshed event,
    Emitter<CompanyListState> emit,
  ) async {
    await _loadCompanies(emit);
  }

  Future<void> _loadCompanies(Emitter<CompanyListState> emit) async {
    emit(state.copyWith(status: CompanyListStatus.loading, errorMessage: null));

    try {
      final companies = await _companyRepository.getCompanies();

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: CompanyListStatus.success,
          companies: companies,
          errorMessage: null,
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: CompanyListStatus.failure,
          errorMessage: readDioErrorMessage(
            e,
            fallback: 'Không thể tải danh sách doanh nghiệp.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: CompanyListStatus.failure,
          errorMessage: 'Không thể tải danh sách doanh nghiệp.',
        ),
      );
    }
  }
}

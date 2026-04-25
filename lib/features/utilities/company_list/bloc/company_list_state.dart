import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';

enum CompanyListStatus {
  initial,
  loading,
  success,
  failure,
}

const _unset = Object();

final class CompanyListState extends Equatable {
  const CompanyListState({
    this.status = CompanyListStatus.initial,
    this.companies = const [],
    this.errorMessage,
  });

  final CompanyListStatus status;
  final List<CompanyModel> companies;
  final String? errorMessage;

  bool get hasCompanies => companies.isNotEmpty;

  CompanyListState copyWith({
    CompanyListStatus? status,
    List<CompanyModel>? companies,
    Object? errorMessage = _unset,
  }) {
    return CompanyListState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, companies, errorMessage];
}

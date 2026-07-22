import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';

enum CompanyListStatus { initial, loading, success, failure }

const _unset = Object();

final class CompanyListState extends Equatable {
  const CompanyListState({
    this.status = CompanyListStatus.initial,
    this.companies = const [],
    this.academicYears = const [],
    this.selectedAcademicYear,
    this.errorMessage,
  });

  final CompanyListStatus status;
  final List<Company> companies;
  final List<AcademicYearOption> academicYears;
  final AcademicYearOption? selectedAcademicYear;
  final String? errorMessage;

  bool get hasCompanies => companies.isNotEmpty;

  CompanyListState copyWith({
    CompanyListStatus? status,
    List<Company>? companies,
    List<AcademicYearOption>? academicYears,
    Object? selectedAcademicYear = _unset,
    Object? errorMessage = _unset,
  }) {
    return CompanyListState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      academicYears: academicYears ?? this.academicYears,
      selectedAcademicYear: identical(selectedAcademicYear, _unset)
          ? this.selectedAcademicYear
          : selectedAcademicYear as AcademicYearOption?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    companies,
    academicYears,
    selectedAcademicYear,
    errorMessage,
  ];
}

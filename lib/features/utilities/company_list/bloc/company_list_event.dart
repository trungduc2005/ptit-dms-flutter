import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';

sealed class CompanyListEvent extends Equatable {
  const CompanyListEvent();

  @override
  List<Object?> get props => [];
}

final class CompanyListStarted extends CompanyListEvent {
  const CompanyListStarted();
}

final class CompanyListRefreshed extends CompanyListEvent {
  const CompanyListRefreshed();
}

final class CompanyListAcademicYearChanged extends CompanyListEvent {
  const CompanyListAcademicYearChanged(this.academicYear);

  final AcademicYearOption academicYear;

  @override
  List<Object?> get props => [academicYear];
}

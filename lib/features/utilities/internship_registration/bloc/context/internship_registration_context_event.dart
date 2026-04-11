import 'package:equatable/equatable.dart';

sealed class InternshipRegistrationContextEvent extends Equatable {
  const InternshipRegistrationContextEvent();

  @override
  List<Object?> get props => [];
}

final class InternshipRegistrationContextStarted
    extends InternshipRegistrationContextEvent {
  const InternshipRegistrationContextStarted({
    required this.studentId,
    this.initialAcademicYearId,
  });

  final String studentId;
  final String? initialAcademicYearId;

  @override
  List<Object?> get props => [studentId, initialAcademicYearId];
}

final class InternshipRegistrationAcademicYearSelected
    extends InternshipRegistrationContextEvent {
  const InternshipRegistrationAcademicYearSelected(this.academicYearId);

  final String academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

final class InternshipRegistrationContextRefreshed
    extends InternshipRegistrationContextEvent {
  const InternshipRegistrationContextRefreshed();
}

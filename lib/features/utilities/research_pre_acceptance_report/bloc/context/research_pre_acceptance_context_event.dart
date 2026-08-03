import 'package:equatable/equatable.dart';

sealed class ResearchPreAcceptanceContextEvent extends Equatable {
  const ResearchPreAcceptanceContextEvent();

  @override
  List<Object?> get props => const [];
}

final class ResearchPreAcceptanceContextStarted
    extends ResearchPreAcceptanceContextEvent {
  const ResearchPreAcceptanceContextStarted();
}

final class ResearchPreAcceptanceContextRefreshed
    extends ResearchPreAcceptanceContextEvent {
  const ResearchPreAcceptanceContextRefreshed();
}

final class ResearchPreAcceptanceAcademicYearSelected
    extends ResearchPreAcceptanceContextEvent {
  const ResearchPreAcceptanceAcademicYearSelected(this.academicYearId);

  final String academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

final class ResearchPreAcceptanceResearchSelected
    extends ResearchPreAcceptanceContextEvent {
  const ResearchPreAcceptanceResearchSelected(this.researchId);

  final String researchId;

  @override
  List<Object?> get props => [researchId];
}

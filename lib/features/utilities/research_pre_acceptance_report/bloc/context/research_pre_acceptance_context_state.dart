import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';

enum ResearchPreAcceptanceContextStatus { initial, loading, success, failure }

const _unset = Object();

final class ResearchPreAcceptanceContextState extends Equatable {
  const ResearchPreAcceptanceContextState({
    this.status = ResearchPreAcceptanceContextStatus.initial,
    this.academicYears = const [],
    this.researches = const [],
    this.selectedAcademicYearId,
    this.selectedResearchId,
    this.errorMessage,
  });

  final ResearchPreAcceptanceContextStatus status;
  final List<AcademicYearOption> academicYears;
  final List<Research> researches;
  final String? selectedAcademicYearId;
  final String? selectedResearchId;
  final String? errorMessage;

  bool get isLoading => status == ResearchPreAcceptanceContextStatus.loading;

  Research? get selectedResearch {
    final researchId = selectedResearchId;
    if (researchId == null) return null;

    for (final research in researches) {
      if (research.researchId == researchId) return research;
    }
    return null;
  }

  ResearchPreAcceptanceContextState copyWith({
    ResearchPreAcceptanceContextStatus? status,
    List<AcademicYearOption>? academicYears,
    List<Research>? researches,
    Object? selectedAcademicYearId = _unset,
    Object? selectedResearchId = _unset,
    Object? errorMessage = _unset,
  }) {
    return ResearchPreAcceptanceContextState(
      status: status ?? this.status,
      academicYears: academicYears ?? this.academicYears,
      researches: researches ?? this.researches,
      selectedAcademicYearId: identical(selectedAcademicYearId, _unset)
          ? this.selectedAcademicYearId
          : selectedAcademicYearId as String?,
      selectedResearchId: identical(selectedResearchId, _unset)
          ? this.selectedResearchId
          : selectedResearchId as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    academicYears,
    researches,
    selectedAcademicYearId,
    selectedResearchId,
    errorMessage,
  ];
}

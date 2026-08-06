import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_seminar_committee.dart';

enum ResearchSeminarCommitteeStatus { initial, loading, success, failure }

const _unset = Object();

final class ResearchSeminarCommitteeState extends Equatable {
  const ResearchSeminarCommitteeState({
    this.status = ResearchSeminarCommitteeStatus.initial,
    this.yearId = '',
    this.researches = const [],
    this.selectedResearchId,
    this.committee,
    this.errorMessage,
  });

  final ResearchSeminarCommitteeStatus status;
  final String yearId;
  final List<ResearchSeminarOption> researches;
  final String? selectedResearchId;
  final ResearchSeminarCommittee? committee;
  final String? errorMessage;

  bool get isLoading => status == ResearchSeminarCommitteeStatus.loading;

  bool get hasCommittee => committee != null;

  bool get isEmpty =>
      status == ResearchSeminarCommitteeStatus.success && researches.isEmpty;

  ResearchSeminarOption? get selectedResearch {
    final researchId = selectedResearchId;
    if (researchId == null) return null;

    for (final research in researches) {
      if (research.researchId == researchId) return research;
    }
    return null;
  }

  ResearchSeminarCommitteeState copyWith({
    ResearchSeminarCommitteeStatus? status,
    String? yearId,
    List<ResearchSeminarOption>? researches,
    Object? selectedResearchId = _unset,
    Object? committee = _unset,
    Object? errorMessage = _unset,
  }) {
    return ResearchSeminarCommitteeState(
      status: status ?? this.status,
      yearId: yearId ?? this.yearId,
      researches: researches ?? this.researches,
      selectedResearchId: identical(selectedResearchId, _unset)
          ? this.selectedResearchId
          : selectedResearchId as String?,
      committee: identical(committee, _unset)
          ? this.committee
          : committee as ResearchSeminarCommittee?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    yearId,
    researches,
    selectedResearchId,
    committee,
    errorMessage,
  ];
}

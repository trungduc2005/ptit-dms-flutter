import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';

enum ResearchFinalCommitteeStatus { initial, loading, success, failure }

const _unset = Object();

final class ResearchFinalCommitteeState extends Equatable {
  const ResearchFinalCommitteeState({
    this.status = ResearchFinalCommitteeStatus.initial,
    this.yearId = '',
    this.researches = const [],
    this.selectedResearchId,
    this.committee,
    this.errorMessage,
  });

  final ResearchFinalCommitteeStatus status;
  final String yearId;
  final List<ResearchFinalOption> researches;
  final String? selectedResearchId;
  final ResearchFinalCommittee? committee;
  final String? errorMessage;

  bool get isLoading => status == ResearchFinalCommitteeStatus.loading;

  bool get hasCommittee => committee != null;

  bool get isEmpty =>
      status == ResearchFinalCommitteeStatus.success && researches.isEmpty;

  ResearchFinalOption? get selectedResearch {
    final researchId = selectedResearchId;
    if (researchId == null) return null;

    for (final research in researches) {
      if (research.researchId == researchId) return research;
    }
    return null;
  }

  ResearchFinalCommitteeState copyWith({
    ResearchFinalCommitteeStatus? status,
    String? yearId,
    List<ResearchFinalOption>? researches,
    Object? selectedResearchId = _unset,
    Object? committee = _unset,
    Object? errorMessage = _unset,
  }) {
    return ResearchFinalCommitteeState(
      status: status ?? this.status,
      yearId: yearId ?? this.yearId,
      researches: researches ?? this.researches,
      selectedResearchId: identical(selectedResearchId, _unset)
          ? this.selectedResearchId
          : selectedResearchId as String?,
      committee: identical(committee, _unset)
          ? this.committee
          : committee as ResearchFinalCommittee?,
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

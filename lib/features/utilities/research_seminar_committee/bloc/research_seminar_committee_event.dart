import 'package:equatable/equatable.dart';

sealed class ResearchSeminarCommitteeEvent extends Equatable {
  const ResearchSeminarCommitteeEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải danh sách đề tài và hội đồng hội thảo theo năm học.
///
/// [researchId] có thể được truyền vào để tải hội đồng của một đề tài cụ thể.
final class ResearchSeminarCommitteeStarted
    extends ResearchSeminarCommitteeEvent {
  const ResearchSeminarCommitteeStarted({
    required this.yearId,
    this.researchId,
  });

  final String yearId;
  final String? researchId;

  @override
  List<Object?> get props => [yearId, researchId];
}

/// Tải lại dữ liệu theo năm học và đề tài đang được chọn trong state.
final class ResearchSeminarCommitteeRefreshed
    extends ResearchSeminarCommitteeEvent {
  const ResearchSeminarCommitteeRefreshed();
}

/// Chọn đề tài và tải hội đồng hội thảo tương ứng.
final class ResearchSeminarCommitteeResearchSelected
    extends ResearchSeminarCommitteeEvent {
  const ResearchSeminarCommitteeResearchSelected(this.researchId);

  final String researchId;

  @override
  List<Object?> get props => [researchId];
}

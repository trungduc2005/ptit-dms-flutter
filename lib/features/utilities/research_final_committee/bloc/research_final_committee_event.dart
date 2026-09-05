import 'package:equatable/equatable.dart';

sealed class ResearchFinalCommitteeEvent extends Equatable {
  const ResearchFinalCommitteeEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải danh sách đề tài và hội đồng nghiệm thu theo năm học.
///
/// [researchId] có thể được truyền vào để tải hội đồng của một đề tài cụ thể.
final class ResearchFinalCommitteeStarted extends ResearchFinalCommitteeEvent {
  const ResearchFinalCommitteeStarted({required this.yearId, this.researchId});

  final String yearId;
  final String? researchId;

  @override
  List<Object?> get props => [yearId, researchId];
}

/// Tải lại dữ liệu theo năm học và đề tài đang được chọn trong state.
final class ResearchFinalCommitteeRefreshed
    extends ResearchFinalCommitteeEvent {
  const ResearchFinalCommitteeRefreshed();
}

/// Chọn đề tài và tải hội đồng nghiệm thu tương ứng.
final class ResearchFinalCommitteeResearchSelected
    extends ResearchFinalCommitteeEvent {
  const ResearchFinalCommitteeResearchSelected(this.researchId);

  final String researchId;

  @override
  List<Object?> get props => [researchId];
}

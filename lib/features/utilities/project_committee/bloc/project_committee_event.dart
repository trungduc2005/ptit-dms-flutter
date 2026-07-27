import 'package:equatable/equatable.dart';

sealed class ProjectCommitteeEvent extends Equatable {
  const ProjectCommitteeEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải thông tin hội đồng của đồ án theo năm học.
final class ProjectCommitteeStarted extends ProjectCommitteeEvent {
  const ProjectCommitteeStarted({required this.academicYearId});

  final String academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

/// Tải lại thông tin hội đồng theo năm học đang được lưu trong state.
final class ProjectCommitteeRefreshed extends ProjectCommitteeEvent {
  const ProjectCommitteeRefreshed();
}

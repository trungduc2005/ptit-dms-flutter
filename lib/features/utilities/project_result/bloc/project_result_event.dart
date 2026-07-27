import 'package:equatable/equatable.dart';

sealed class ProjectResultEvent extends Equatable {
  const ProjectResultEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải kết quả của đồ án theo mã đồ án.
final class ProjectResultStarted extends ProjectResultEvent {
  const ProjectResultStarted({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

/// Tải lại kết quả theo mã đồ án đang được lưu trong state.
final class ProjectResultRefreshed extends ProjectResultEvent {
  const ProjectResultRefreshed();
}

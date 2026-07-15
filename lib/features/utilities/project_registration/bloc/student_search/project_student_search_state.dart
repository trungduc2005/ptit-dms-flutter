import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

sealed class ProjectStudentSearchState extends Equatable {
  const ProjectStudentSearchState();

  @override
  List<Object?> get props => [];
}

/// Chưa có query nào (ban đầu hoặc sau khi clear).
final class ProjectStudentSearchInitial extends ProjectStudentSearchState {
  const ProjectStudentSearchInitial();
}

/// Đang chờ debounce hoặc đang gọi API.
final class ProjectStudentSearchLoading extends ProjectStudentSearchState {
  const ProjectStudentSearchLoading(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Đã có kết quả.
final class ProjectStudentSearchLoaded extends ProjectStudentSearchState {
  const ProjectStudentSearchLoaded({
    required this.query,
    required this.results,
  });

  final String query;
  final List<StudentSearchResult> results;

  @override
  List<Object?> get props => [query, results];
}

/// Không có kết quả.
final class ProjectStudentSearchEmpty extends ProjectStudentSearchState {
  const ProjectStudentSearchEmpty(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Lỗi khi tìm kiếm.
final class ProjectStudentSearchError extends ProjectStudentSearchState {
  const ProjectStudentSearchError({
    required this.query,
    required this.message,
  });

  final String query;
  final String message;

  @override
  List<Object?> get props => [query, message];
}

extension ProjectStudentSearchStateX on ProjectStudentSearchState {
  bool get isLoading => this is ProjectStudentSearchLoading;

  List<StudentSearchResult> get results =>
      this is ProjectStudentSearchLoaded
          ? (this as ProjectStudentSearchLoaded).results
          : const [];

  String? get error =>
      this is ProjectStudentSearchError
          ? (this as ProjectStudentSearchError).message
          : null;
}

import 'package:equatable/equatable.dart';

abstract class ProjectStudentSearchEvent extends Equatable {
  const ProjectStudentSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Sinh viên nhập text vào ô tìm kiếm (được debounce 350ms).
final class ProjectStudentSearchQueryChanged extends ProjectStudentSearchEvent {
  const ProjectStudentSearchQueryChanged({
    required this.query,
    required this.academicYearId,
  });
  final String query;
  final String academicYearId;

  @override
  List<Object?> get props => [query, academicYearId];
}

/// Xóa kết quả tìm kiếm.
final class ProjectStudentSearchCleared extends ProjectStudentSearchEvent {
  const ProjectStudentSearchCleared();
}

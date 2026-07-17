import 'package:equatable/equatable.dart';

sealed class ProjectRegistrationContextEvent extends Equatable {
  const ProjectRegistrationContextEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo trang đăng ký đồ án.
///
/// BLoC sẽ tự động load profile và student info.
final class ProjectRegistrationContextStarted
    extends ProjectRegistrationContextEvent {
  const ProjectRegistrationContextStarted({this.initialAcademicYearId});

  final String? initialAcademicYearId;

  @override
  List<Object?> get props => [initialAcademicYearId];
}

/// Sinh viên thay đổi năm học trong dropdown.
final class ProjectRegistrationAcademicYearSelected
    extends ProjectRegistrationContextEvent {
  const ProjectRegistrationAcademicYearSelected(this.academicYearId);

  final String academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}

/// Làm mới trạng thái (sau khi đăng ký/cập nhật thành công).
final class ProjectRegistrationContextRefreshed
    extends ProjectRegistrationContextEvent {
  const ProjectRegistrationContextRefreshed();
}

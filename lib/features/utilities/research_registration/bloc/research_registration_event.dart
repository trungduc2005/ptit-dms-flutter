import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';

sealed class ResearchRegistrationEvent extends Equatable {
  const ResearchRegistrationEvent();

  @override
  List<Object?> get props => const [];
}

/// Tải các đề tài nghiên cứu của người dùng theo năm học và loại nghiên cứu.
final class ResearchRegistrationStarted extends ResearchRegistrationEvent {
  const ResearchRegistrationStarted({required this.yearId, required this.type});

  final String yearId;
  final String type;

  @override
  List<Object?> get props => [yearId, type];
}

/// Tải lại dữ liệu bằng năm học và loại nghiên cứu đang có trong state.
final class ResearchRegistrationRefreshed extends ResearchRegistrationEvent {
  const ResearchRegistrationRefreshed();
}

/// Đăng ký một đề tài nghiên cứu khoa học mới.
final class ResearchRegistrationCreated extends ResearchRegistrationEvent {
  const ResearchRegistrationCreated({required this.request});

  final ResearchRegistrationRequest request;

  @override
  List<Object?> get props => [request];
}

/// Cập nhật một đề tài nghiên cứu khoa học chưa được duyệt.
final class ResearchRegistrationUpdated extends ResearchRegistrationEvent {
  const ResearchRegistrationUpdated({
    required this.researchId,
    required this.request,
  });

  /// Mã nghiệp vụ của đề tài, không phải MongoDB `_id`.
  final String researchId;
  final ResearchRegistrationRequest request;

  @override
  List<Object?> get props => [researchId, request];
}

/// Đưa trạng thái tạo/cập nhật về initial sau khi UI đã xử lý thông báo.
final class ResearchRegistrationActionStateCleared
    extends ResearchRegistrationEvent {
  const ResearchRegistrationActionStateCleared();
}

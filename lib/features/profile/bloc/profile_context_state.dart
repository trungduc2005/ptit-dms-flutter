import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';

enum ProfileContextStatus { initial, loading, success, failure }

const _unset = Object();

final class ProfileContextState extends Equatable {
  const ProfileContextState({
    this.status = ProfileContextStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final ProfileContextStatus status;
  final StudentProfile? profile;
  final String? errorMessage;

  bool get hasProfile => profile != null;

  ProfileContextState copyWith({
    ProfileContextStatus? status,
    Object? profile = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProfileContextState(
      status: status ?? this.status,
      profile: identical(profile, _unset)
          ? this.profile
          : profile as StudentProfile?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

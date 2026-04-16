import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_update_request_model.dart';

sealed class ProfileSubmitEvent extends Equatable {
  const ProfileSubmitEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileUpdateSubmitted extends ProfileSubmitEvent {
  const ProfileUpdateSubmitted({
    required this.request,
  });

  final StudentProfileUpdateRequestModel request;

  @override
  List<Object?> get props => [request];
}

final class ProfileAvatarUploadRequested extends ProfileSubmitEvent {
  const ProfileAvatarUploadRequested({
    required this.filePath,
  });

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

final class ProfileSubmitStateCleared extends ProfileSubmitEvent {
  const ProfileSubmitStateCleared();
}

import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';

enum ProfileSubmitStatus { initial, loading, success, failure }

enum ProfileAvatarUploadStatus { initial, loading, success, failure }

const _unset = Object();

final class ProfileSubmitState extends Equatable {
  const ProfileSubmitState({
    this.submitStatus = ProfileSubmitStatus.initial,
    this.uploadStatus = ProfileAvatarUploadStatus.initial,
    this.updatedProfile,
    this.uploadedAvatar,
    this.message,
  });

  final ProfileSubmitStatus submitStatus;
  final ProfileAvatarUploadStatus uploadStatus;
  final StudentProfile? updatedProfile;
  final AvatarUploadResult? uploadedAvatar;
  final String? message;

  bool get isBusy =>
      submitStatus == ProfileSubmitStatus.loading ||
      uploadStatus == ProfileAvatarUploadStatus.loading;

  ProfileSubmitState copyWith({
    ProfileSubmitStatus? submitStatus,
    ProfileAvatarUploadStatus? uploadStatus,
    Object? updatedProfile = _unset,
    Object? uploadedAvatar = _unset,
    Object? message = _unset,
  }) {
    return ProfileSubmitState(
      submitStatus: submitStatus ?? this.submitStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      updatedProfile: identical(updatedProfile, _unset)
          ? this.updatedProfile
          : updatedProfile as StudentProfile?,
      uploadedAvatar: identical(uploadedAvatar, _unset)
          ? this.uploadedAvatar
          : uploadedAvatar as AvatarUploadResult?,
      message: identical(message, _unset) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [
    submitStatus,
    uploadStatus,
    updatedProfile,
    uploadedAvatar,
    message,
  ];
}

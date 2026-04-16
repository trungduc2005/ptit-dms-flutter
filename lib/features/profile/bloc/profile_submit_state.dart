import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_avatar_upload_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_model.dart';

enum ProfileSubmitStatus {
  initial,
  loading,
  success,
  failure,
}

enum ProfileAvatarUploadStatus {
  initial,
  loading,
  success,
  failure,
}

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
  final StudentProfileModel? updatedProfile;
  final StudentProfileAvatarUploadModel? uploadedAvatar;
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
          : updatedProfile as StudentProfileModel?,
      uploadedAvatar: identical(uploadedAvatar, _unset)
          ? this.uploadedAvatar
          : uploadedAvatar as StudentProfileAvatarUploadModel?,
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

import 'package:ptit_dms_flutter/data/models/student_profile_avatar_upload_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_update_request_model.dart';
import 'package:ptit_dms_flutter/data/models/required_profile_check_model.dart';
import 'package:ptit_dms_flutter/data/models/required_profile_update_request_model.dart';

abstract class StudentProfileRepository {
  Future<StudentProfileModel> getProfile();

  Future<StudentProfileModel> updateProfile({
    required StudentProfileUpdateRequestModel request,
  });

  Future<StudentProfileAvatarUploadModel> uploadAvatar({
    required String filePath,
  });

  Future<RequiredProfileCheckModel> checkRequiredProfile();

  Future<void> updateRequiredProfile({
    required RequiredProfileUpdateRequestModel request,
  });
}

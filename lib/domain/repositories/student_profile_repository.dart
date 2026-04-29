import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_check.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_update_request.dart';

abstract class StudentProfileRepository {
  Future<StudentProfile> getProfile();

  Future<StudentProfile> updateProfile({
    required StudentProfileUpdateRequest request,
  });

  Future<AvatarUploadResult> uploadAvatar({required String filePath});

  Future<RequiredProfileCheck> checkRequiredProfile();

  Future<void> updateRequiredProfile({
    required RequiredProfileUpdateRequest request,
  });
}

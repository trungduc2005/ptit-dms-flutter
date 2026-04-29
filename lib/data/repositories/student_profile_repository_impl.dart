import 'package:ptit_dms_flutter/data/datasources/student_profile_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_check.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_update_request.dart';

class StudentProfileRepositoryImpl implements StudentProfileRepository {
  StudentProfileRepositoryImpl(this._remoteDataSource);

  final StudentProfileRemoteDataSource _remoteDataSource;

  @override
  Future<StudentProfile> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<StudentProfile> updateProfile({
    required StudentProfileUpdateRequest request,
  }) {
    return _remoteDataSource.updateProfile(request: request);
  }

  @override
  Future<AvatarUploadResult> uploadAvatar({required String filePath}) {
    return _remoteDataSource.uploadAvatar(filePath: filePath);
  }

  @override
  Future<RequiredProfileCheck> checkRequiredProfile() {
    return _remoteDataSource.checkRequiredProfile();
  }

  @override
  Future<void> updateRequiredProfile({
    required RequiredProfileUpdateRequest request,
  }) {
    return _remoteDataSource.updateRequiredProfile(request: request);
  }
}

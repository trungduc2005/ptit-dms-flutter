import 'package:ptit_dms_flutter/data/datasources/student_profile_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_avatar_upload_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_update_request_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';

class StudentProfileRepositoryImpl implements StudentProfileRepository {
  StudentProfileRepositoryImpl(this._remoteDataSource);

  final StudentProfileRemoteDataSource _remoteDataSource;

  @override
  Future<StudentProfileModel> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<StudentProfileModel> updateProfile({
    required StudentProfileUpdateRequestModel request,
  }) {
    return _remoteDataSource.updateProfile(request: request);
  }

  @override
  Future<StudentProfileAvatarUploadModel> uploadAvatar({
    required String filePath,
  }) {
    return _remoteDataSource.uploadAvatar(filePath: filePath);
  }
}

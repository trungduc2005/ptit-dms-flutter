import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_check.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_update_request.dart';

class StudentProfileRemoteDataSource {
  StudentProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<StudentProfile> getProfile() async {
    final response = await _dio.get(
      '/info',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return StudentProfile.fromJson(asJsonMap(response.data));
  }

  Future<StudentProfile> updateProfile({
    required StudentProfileUpdateRequest request,
  }) async {
    final response = await _dio.put(
      '/info/update',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return StudentProfile.fromJson(_asInfoJsonMap(response.data));
  }

  Future<AvatarUploadResult> uploadAvatar({required String filePath}) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: _extractFileName(filePath),
      ),
    });

    final response = await _dio.post(
      '/info/upload-avatar',
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        extra: const {requiresBearerAuthKey: true},
      ),
    );

    return AvatarUploadResult.fromJson(asJsonMap(response.data));
  }

  Future<RequiredProfileCheck> checkRequiredProfile() async {
    final response = await _dio.get(
      '/users/check-profile',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return RequiredProfileCheck.fromJson(asJsonMap(response.data));
  }

  Future<void> updateRequiredProfile({
    required RequiredProfileUpdateRequest request,
  }) async {
    await _dio.put(
      '/users/update-profile-required',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );
  }

  Map<String, dynamic> _asInfoJsonMap(Object? data) {
    final json = asJsonMap(data);
    final info = json['info'];

    if (info is Map<String, dynamic>) {
      return info;
    }

    if (info is Map) {
      return Map<String, dynamic>.from(info);
    }

    return json;
  }

  String _extractFileName(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final segments = normalized.split('/');

    if (segments.isEmpty) {
      return filePath;
    }

    return segments.last;
  }
}

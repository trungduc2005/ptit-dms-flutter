import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_avatar_upload_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_model.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_update_request_model.dart';

class StudentProfileRemoteDataSource {
  StudentProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<StudentProfileModel> getProfile() async {
    final response = await _dio.get(
      '/info',
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return StudentProfileModel.fromJson(_asJsonMap(response.data));
  }

  Future<StudentProfileModel> updateProfile({
    required StudentProfileUpdateRequestModel request,
  }) async {
    final response = await _dio.put(
      '/info/update',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return StudentProfileModel.fromJson(_asInfoJsonMap(response.data));
  }

  Future<StudentProfileAvatarUploadModel> uploadAvatar({
    required String filePath,
  }) async {
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

    return StudentProfileAvatarUploadModel.fromJson(_asJsonMap(response.data));
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _asInfoJsonMap(Object? data) {
    final json = _asJsonMap(data);
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

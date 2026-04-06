import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_check_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_cv_download_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';
import 'package:ptit_dms_flutter/data/models/current_intern_registration_model.dart';

class InternRegistrationRemoteDataSource {
  InternRegistrationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<InternRegistrationModel> registerInternship({
    required InternRegistrationRequestModel request,
  }) async {
    final response = await _dio.post(
      '/interns/registrations/register',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return InternRegistrationModel.fromJson(_asJsonMap(response.data));
  }

  Future<InternRegistrationModel> updateInternship({
    required InternRegistrationRequestModel request,
  }) async {
    final response = await _dio.put(
      '/interns/registrations/update',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return InternRegistrationModel.fromJson(_asJsonMap(response.data));
  }

  Future<CurrentInternRegistrationModel> getCurrentRegistration({
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/interns/registrations',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return CurrentInternRegistrationModel.fromJson(_asJsonMap(response.data));
  }

  Future<InternRegistrationCheckModel> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/interns/registrations/check-intern/$studentId',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return InternRegistrationCheckModel.fromJson(_asJsonMap(response.data));
  }

  Future<InternRegistrationCvDownloadModel> downloadRegistrationCv({
    required String studentId,
    required String academicYearId,
  }) async {
    final response = await _dio.get<List<int>>(
      '/interns/registrations/$studentId/cv/download',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(
        responseType: ResponseType.bytes,
        extra: const {requiresBearerAuthKey: true},
      ),
    );

    return InternRegistrationCvDownloadModel(
      bytes: _asBytes(response.data),
      fileName: _extractFileName(response.headers) ?? '$studentId-cv.pdf',
      contentType: response.headers.value(Headers.contentTypeHeader),
    );
  }

  Uint8List _asBytes(Object? data) {
    if (data is Uint8List) {
      return data;
    }

    if (data is List<int>) {
      return Uint8List.fromList(data);
    }

    if (data is List) {
      return Uint8List.fromList(
        data.map((item) => item is int ? item : 0).toList(growable: false),
      );
    }

    return Uint8List(0);
  }

  String? _extractFileName(Headers headers) {
    final contentDisposition = headers.value('content-disposition');

    if (contentDisposition == null || contentDisposition.isEmpty) {
      return null;
    }

    final utf8Match = RegExp(
      r"filename\*=UTF-8''([^;]+)",
    ).firstMatch(contentDisposition);
    if (utf8Match != null) {
      return Uri.decodeComponent(utf8Match.group(1)!);
    }

    final basicMatch = RegExp(
      r'filename="?([^"]+)"?',
    ).firstMatch(contentDisposition);
    return basicMatch?.group(1);
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    Object? source = data;

    if (data is Map && data['data'] is Map) {
      source = data['data'];
    }

    if (source is Map<String, dynamic>) {
      return source;
    }

    if (source is Map) {
      return Map<String, dynamic>.from(source);
    }

    return <String, dynamic>{};
  }
}

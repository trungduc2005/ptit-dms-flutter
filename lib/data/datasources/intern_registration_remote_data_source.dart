import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/core/utils/json_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/current_intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_check.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_cv_download.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration_request.dart';

class InternRegistrationRemoteDataSource {
  InternRegistrationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<InternRegistration> registerInternship({
    required InternRegistrationRequest request,
  }) async {
    final response = await _dio.post(
      '/interns/registrations',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return InternRegistration.fromJson(
      asJsonMap(response.data, unwrapData: true),
    );
  }

  Future<InternRegistration> updateInternship({
    required InternRegistrationRequest request,
  }) async {
    final response = await _dio.put(
      '/interns/registrations',
      data: request.toJson(),
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return InternRegistration.fromJson(
      asJsonMap(response.data, unwrapData: true),
    );
  }

  Future<CurrentInternRegistration?> getCurrentRegistration({
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/interns/registrations',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    final json = asNullableJsonMap(response.data, unwrapData: true);
    if (json == null || !_looksLikeCurrentRegistrationPayload(json)) {
      return null;
    }

    return CurrentInternRegistration.fromJson(json);
  }

  Future<InternRegistrationCheck> checkInternRegistration({
    required String studentId,
    required String academicYearId,
  }) async {
    final response = await _dio.get(
      '/interns/registrations/check-intern/$studentId',
      queryParameters: {'academicYearId': academicYearId},
      options: Options(extra: const {requiresBearerAuthKey: true}),
    );

    return InternRegistrationCheck.fromJson(
      asJsonMap(response.data, unwrapData: true),
    );
  }

  Future<InternRegistrationCvDownload> downloadRegistrationCv({
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

    final bytes = _asBytes(response.data);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Không nhận được dữ liệu file CV hợp lệ.');
    }

    return InternRegistrationCvDownload(
      bytes: bytes,
      fileName: _extractFileName(response.headers) ?? '$studentId-cv.pdf',
      contentType: response.headers.value(Headers.contentTypeHeader),
    );
  }

  Uint8List? _asBytes(Object? data) {
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

    return null;
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

  bool _looksLikeCurrentRegistrationPayload(Map<String, dynamic> json) {
    return json.containsKey('_id') ||
        json.containsKey('internId') ||
        json.containsKey('studentId') ||
        json.containsKey('type');
  }
}

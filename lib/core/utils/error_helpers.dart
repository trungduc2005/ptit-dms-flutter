import 'package:dio/dio.dart';

String readDioErrorMessage(DioException error, {String? fallback}) {
  final responseData = error.response?.data;
  if (responseData is Map && responseData['message'] != null) {
    return responseData['message'].toString();
  }

  return error.message ?? fallback ?? 'Đã xảy ra lỗi.';
}

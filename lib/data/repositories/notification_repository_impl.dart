import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/notification_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/notification.dart';
import 'package:ptit_dms_flutter/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteDataSource, this._mapper);

  final NotificationRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<NotificationPage> getNotifications({
    int limit = 20,
    DateTime? cursor,
    bool unreadOnly = false,
  }) async {
    try {
      return await _remoteDataSource.getNotifications(
        limit: limit,
        cursor: cursor,
        unreadOnly: unreadOnly,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu thông báo không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      return await _remoteDataSource.markAllAsRead();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu trạng thái thông báo không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

import 'package:ptit_dms_flutter/data/datasources/timeline_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._remoteDataSource);

  final TimelineRemoteDataSource _remoteDataSource;

  @override
  Future<List<Timeline>> getInternTimelines({required String academicYearId}) {
    return _remoteDataSource.getInternTimelines(academicYearId: academicYearId);
  }
}

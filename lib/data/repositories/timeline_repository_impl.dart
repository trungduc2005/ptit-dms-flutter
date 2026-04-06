import 'package:ptit_dms_flutter/data/datasources/timeline_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/timeline_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._remoteDataSource);

  final TimelineRemoteDataSource _remoteDataSource;

  @override
  Future<List<TimelineModel>> getInternTimelines({
    required String academicYearId,
  }) {
    return _remoteDataSource.getInternTimelines(
      academicYearId: academicYearId,
    );
  }
}

import 'package:ptit_dms_flutter/data/models/timeline_model.dart';

abstract class TimelineRepository {
  Future<List<TimelineModel>> getInternTimelines({
    required String academicYearId,
  });
}

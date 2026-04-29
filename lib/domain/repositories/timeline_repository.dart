import 'package:ptit_dms_flutter/domain/entities/timeline.dart';

abstract class TimelineRepository {
  Future<List<Timeline>> getInternTimelines({required String academicYearId});
}

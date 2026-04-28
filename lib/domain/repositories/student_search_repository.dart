import 'package:ptit_dms_flutter/data/models/student_search_result_model.dart';

abstract class StudentSearchRepository {
  Future<List<StudentSearchResultModel>> searchInternEligibleStudents({
    required String query,
    required String academicYearId,
  });
}

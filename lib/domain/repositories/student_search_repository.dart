import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';

abstract class StudentSearchRepository {
  Future<List<StudentSearchResult>> searchInternEligibleStudents({
    required String query,
    required String academicYearId,
  });

  Future<List<StudentSearchResult>> searchProjectEligibleStudents({
    required String query,
    required String academicYearId,
  });
}

import 'package:ptit_dms_flutter/data/datasources/student_search_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/student_search_result.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_search_repository.dart';

class StudentSearchRepositoryImpl implements StudentSearchRepository {
  StudentSearchRepositoryImpl(this._remoteDataSource);

  final StudentSearchRemoteDataSource _remoteDataSource;

  @override
  Future<List<StudentSearchResult>> searchInternEligibleStudents({
    required String query,
    required String academicYearId,
  }) {
    return _remoteDataSource.searchInternEligibleStudents(
      query: query,
      academicYearId: academicYearId,
    );
  }
}

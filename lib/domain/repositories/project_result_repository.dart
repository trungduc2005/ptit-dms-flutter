import 'package:ptit_dms_flutter/domain/entities/project_result.dart';

abstract interface class ProjectResultRepository {
  Future<ProjectResult> getProjectResult({
    required String projectId,
    required String academicYearId,
  });
}

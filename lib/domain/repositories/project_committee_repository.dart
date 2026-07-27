import 'package:ptit_dms_flutter/domain/entities/project_committee.dart';

abstract interface class ProjectCommitteeRepository {
  Future<ProjectCommittee> getMyProjectCommittee({
    required String academicYearId,
  });
}

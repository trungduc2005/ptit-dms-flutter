import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_pre_defense_submission_request.dart';

typedef ProjectUploadProgressCallback =
    void Function(int sentBytes, int totalBytes);

abstract interface class ProjectPreDefenseSubmissionRepository {
  Future<ProjectPreDefenseSubmission> getSubmission({
    required String projectId,
    required String academicYearId,
  });

  Future<void> uploadSubmission({
    required ProjectPreDefenseSubmissionRequest request,
    ProjectUploadProgressCallback? onSendProgress,
  });
}

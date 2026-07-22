import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission.dart';
import 'package:ptit_dms_flutter/domain/entities/project_post_defense_submission_request.dart';

typedef ProjectPostDefenseUploadProgressCallback =
    void Function(int sentBytes, int totalBytes);

abstract interface class ProjectPostDefenseSubmissionRepository {
  Future<ProjectPostDefenseSubmission> getSubmission({
    required String projectId,
    required String academicYearId,
  });

  Future<void> uploadSubmission({
    required ProjectPostDefenseSubmissionRequest request,
    ProjectPostDefenseUploadProgressCallback? onSendProgress,
  });
}

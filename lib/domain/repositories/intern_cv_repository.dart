import 'package:ptit_dms_flutter/domain/entities/intern_cv_upload_result.dart';

abstract class InternCvRepository {
  Future<InternCvUploadResult> uploadCv({
    required String academicYearId,
    required String filePath,
    String? studentId,
  });
}

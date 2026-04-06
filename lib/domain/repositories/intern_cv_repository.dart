import 'package:ptit_dms_flutter/data/models/intern_cv_upload_result_model.dart';

abstract class InternCvRepository {
  Future<InternCvUploadResultModel> uploadCv({
    required String academicYearId,
    required String filePath,
  });
}

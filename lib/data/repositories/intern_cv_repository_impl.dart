import 'package:ptit_dms_flutter/data/datasources/intern_cv_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/intern_cv_upload_result_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';

class InternCvRepositoryImpl implements InternCvRepository {
  InternCvRepositoryImpl(this._remoteDataSource);

  final InternCvRemoteDataSource _remoteDataSource;

  @override
  Future<InternCvUploadResultModel> uploadCv({
    required String academicYearId,
    required String filePath,
  }) {
    return _remoteDataSource.uploadCv(
      academicYearId: academicYearId,
      filePath: filePath,
    );
  }
}

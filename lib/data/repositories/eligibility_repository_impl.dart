import 'package:ptit_dms_flutter/data/datasources/eligibility_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/eligibility_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';

class EligibilityRepositoryImpl implements EligibilityRepository {
  EligibilityRepositoryImpl(this._remoteDataSource);

  final EligibilityRemoteDataSource _remoteDataSource;

  @override
  Future<EligibilityModel> getRegistrationEligibility({
    required String academicYearId,
  }) {
    return _remoteDataSource.getRegistrationEligibility(
      academicYearId: academicYearId,
    );
  }
}

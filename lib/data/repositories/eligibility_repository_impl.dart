import 'package:ptit_dms_flutter/data/datasources/eligibility_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/eligibility.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';

class EligibilityRepositoryImpl implements EligibilityRepository {
  EligibilityRepositoryImpl(this._remoteDataSource);

  final EligibilityRemoteDataSource _remoteDataSource;

  @override
  Future<Eligibility> getRegistrationEligibility({
    required String academicYearId,
  }) {
    return _remoteDataSource.getRegistrationEligibility(
      academicYearId: academicYearId,
    );
  }
}

import 'package:ptit_dms_flutter/domain/entities/eligibility.dart';

abstract class EligibilityRepository {
  Future<Eligibility> getRegistrationEligibility({
    required String academicYearId,
  });
}

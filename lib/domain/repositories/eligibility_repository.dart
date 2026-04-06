import 'package:ptit_dms_flutter/data/models/eligibility_model.dart';

abstract class EligibilityRepository {
  Future<EligibilityModel> getRegistrationEligibility({
    required String academicYearId,
  });
}

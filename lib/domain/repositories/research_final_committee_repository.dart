import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';

abstract interface class ResearchFinalCommitteeRepository {
  Future<ResearchFinalCommitteeResult> getMyCommittee({
    required String yearId,
    String? researchId,
  });
}

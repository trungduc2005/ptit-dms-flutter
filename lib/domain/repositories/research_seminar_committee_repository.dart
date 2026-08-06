import 'package:ptit_dms_flutter/domain/entities/research_seminar_committee.dart';

abstract interface class ResearchSeminarCommitteeRepository {
  Future<ResearchSeminarCommitteeResult> getMyCommittee({
    required String yearId,
    String? researchId,
  });
}

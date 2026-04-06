import 'package:ptit_dms_flutter/data/models/academic_year_option_model.dart';

abstract class AcademicYearRepository {
  Future<List<AcademicYearOptionModel>> getInternAcademicYears();
}
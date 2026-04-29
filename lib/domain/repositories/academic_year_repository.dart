import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';

abstract class AcademicYearRepository {
  Future<List<AcademicYearOption>> getInternAcademicYears();
}

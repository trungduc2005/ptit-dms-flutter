import 'package:ptit_dms_flutter/domain/entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> getCompanies();
}

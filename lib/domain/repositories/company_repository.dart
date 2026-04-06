import 'package:ptit_dms_flutter/data/models/company_model.dart';

abstract class CompanyRepository {
  Future<List<CompanyModel>> getCompanies();
}
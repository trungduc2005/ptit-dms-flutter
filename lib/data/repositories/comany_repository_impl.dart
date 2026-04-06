import 'package:ptit_dms_flutter/data/datasources/company_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';

class ComanyRepositoryImpl implements CompanyRepository{
  ComanyRepositoryImpl(this._companyRemoteDataSource);

  final CompanyRemoteDataSource _companyRemoteDataSource;

  @override
  Future<List<CompanyModel>> getCompanies() {
    return _companyRemoteDataSource.getCompanies();
  }
}
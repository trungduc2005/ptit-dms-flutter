import 'package:ptit_dms_flutter/data/datasources/company_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl(this._remoteDataSource);

  final CompanyRemoteDataSource _remoteDataSource;

  @override
  Future<List<CompanyModel>> getCompanies() {
    return _remoteDataSource.getCompanies();
  }
}

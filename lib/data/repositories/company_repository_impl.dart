import 'package:ptit_dms_flutter/data/datasources/company_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl(this._remoteDataSource);

  final CompanyRemoteDataSource _remoteDataSource;

  @override
  Future<List<Company>> getCompanies() {
    return _remoteDataSource.getCompanies();
  }
}

import 'package:ptit_dms_flutter/data/datasources/academic_year_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';

class AcademicYearRepositoryImpl implements AcademicYearRepository {
  AcademicYearRepositoryImpl(this._remoteDataSource);

  final AcademicYearRemoteDataSource _remoteDataSource;

  @override
  Future<List<AcademicYearOption>> getInternAcademicYears() {
    return _remoteDataSource.getInternAcademicYears();
  }
}

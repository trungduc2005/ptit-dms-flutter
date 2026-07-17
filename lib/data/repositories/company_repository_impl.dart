import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/company_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl(this._remoteDataSource, this._mapper);

  final CompanyRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<Company>> getCompanies({
    required String academicYearCode,
    String search = '',
  }) async {  
    try {
      return await _remoteDataSource.getCompanies(
        academicYearCode: academicYearCode,
        search: search,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu doanh nghiệp không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}
import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/academic_year_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';

class AcademicYearRepositoryImpl implements AcademicYearRepository {
  AcademicYearRepositoryImpl(this._remoteDataSource, this._mapper);

  final AcademicYearRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<List<AcademicYearOption>> getInternAcademicYears() async {
    try {
      return await _remoteDataSource.getInternAcademicYears();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<List<AcademicYearOption>> getProjectAcademicYears() async {
    try {
      return await _remoteDataSource.getProjectAcademicYears();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}
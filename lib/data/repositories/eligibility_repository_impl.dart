import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/eligibility_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/eligibility.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';

class EligibilityRepositoryImpl implements EligibilityRepository {
  EligibilityRepositoryImpl(this._remoteDataSource, this._mapper);

  final EligibilityRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<Eligibility> getRegistrationEligibility({
    required String academicYearId,
  }) async {
    try {
      return await _remoteDataSource.getRegistrationEligibility(
        academicYearId: academicYearId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    }
  }
}
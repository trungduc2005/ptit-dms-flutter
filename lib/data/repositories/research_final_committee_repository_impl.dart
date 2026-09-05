import 'package:dio/dio.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_final_committee_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_final_committee_repository.dart';

class ResearchFinalCommitteeRepositoryImpl
    implements ResearchFinalCommitteeRepository {
  ResearchFinalCommitteeRepositoryImpl(this._remoteDataSource, this._mapper);

  final ResearchFinalCommitteeRemoteDataSource _remoteDataSource;
  final DioExceptionMapper _mapper;

  @override
  Future<ResearchFinalCommitteeResult> getMyCommittee({
    required String yearId,
    String? researchId,
  }) async {
    try {
      return await _remoteDataSource.getMyCommittee(
        yearId: yearId,
        researchId: researchId,
      );
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapper.map(error, stackTrace), stackTrace);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        UnexpectedException(
          'Dữ liệu hội đồng nghiệm thu không hợp lệ.',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}

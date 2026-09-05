import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_final_committee_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/research_final_committee_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';

typedef _GetMyCommitteeCallback =
    Future<ResearchFinalCommitteeResult> Function({
      required String yearId,
      String? researchId,
    });

class _FakeRemoteDataSource extends Fake
    implements ResearchFinalCommitteeRemoteDataSource {
  _FakeRemoteDataSource(this.callback);

  final _GetMyCommitteeCallback callback;

  @override
  Future<ResearchFinalCommitteeResult> getMyCommittee({
    required String yearId,
    String? researchId,
  }) {
    return callback(yearId: yearId, researchId: researchId);
  }
}

void main() {
  const mapper = DioExceptionMapper();

  ResearchFinalCommitteeRepositoryImpl createRepository(
    _GetMyCommitteeCallback callback,
  ) {
    return ResearchFinalCommitteeRepositoryImpl(
      _FakeRemoteDataSource(callback),
      mapper,
    );
  }

  group('ResearchFinalCommitteeRepositoryImpl', () {
    test('forwards parameters and returns datasource result', () async {
      String? capturedYearId;
      String? capturedResearchId;
      const expected = ResearchFinalCommitteeResult(
        researches: <ResearchFinalOption>[],
        committee: null,
      );
      final repository = createRepository(({
        required yearId,
        researchId,
      }) async {
        capturedYearId = yearId;
        capturedResearchId = researchId;
        return expected;
      });

      final result = await repository.getMyCommittee(
        yearId: 'YEAR-01',
        researchId: 'RESEARCH-01',
      );

      expect(capturedYearId, 'YEAR-01');
      expect(capturedResearchId, 'RESEARCH-01');
      expect(result, same(expected));
    });

    test('maps DioException to AppException', () {
      final repository = createRepository(({required yearId, researchId}) {
        throw DioException(
          requestOptions: RequestOptions(
            path: '/researches/committees/my/finalResearchCommittee',
          ),
          type: DioExceptionType.connectionTimeout,
        );
      });

      expect(
        () => repository.getMyCommittee(yearId: 'YEAR-01'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps malformed response to UnexpectedException', () {
      final repository = createRepository(({required yearId, researchId}) {
        throw const FormatException('malformed committee');
      });

      expect(
        () => repository.getMyCommittee(yearId: 'YEAR-01'),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu hội đồng nghiệm thu không hợp lệ.',
          ),
        ),
      );
    });
  });
}

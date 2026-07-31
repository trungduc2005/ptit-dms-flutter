import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/research_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/research_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';

typedef _CreateResearchCallback =
    Future<Research> Function({required ResearchRegistrationRequest request});

class _FakeResearchRemoteDataSource extends Fake
    implements ResearchRemoteDataSource {
  _FakeResearchRemoteDataSource(this._createCallback);

  final _CreateResearchCallback _createCallback;

  @override
  Future<Research> createResearch({
    required ResearchRegistrationRequest request,
  }) {
    return _createCallback(request: request);
  }
}

DioException _dioError(DioExceptionType type, {int? statusCode, Object? data}) {
  final requestOptions = RequestOptions(path: '/researches');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          ),
  );
}

const _request = ResearchRegistrationRequest(
  yearId: 'year-01',
  type: 'student',
  level: 'Cấp trường',
  researchTopic: 'Ứng dụng AI trong giáo dục',
  keyword: 'AI, giáo dục',
  outcome: 'Bài báo khoa học',
  description: 'Nghiên cứu ứng dụng AI',
  researchNecessity: 'Nâng cao chất lượng đào tạo',
  nationalOverview: 'Tổng quan trong nước',
  internationalOverview: 'Tổng quan quốc tế',
  members: [ResearchRegistrationMemberRequest(memberId: 'B23DCCN002')],
);

const _research = Research(
  id: 'research-ref-01',
  userId: 'user-01',
  researchId: 'RESEARCH-01',
  type: 'student',
  level: 'Cấp trường',
  researchTopic: 'Ứng dụng AI trong giáo dục',
  keyword: 'AI, giáo dục',
  outcome: 'Bài báo khoa học',
  description: 'Nghiên cứu ứng dụng AI',
  researchNecessity: 'Nâng cao chất lượng đào tạo',
  nationalOverview: 'Tổng quan trong nước',
  internationalOverview: 'Tổng quan quốc tế',
  yearId: 'year-01',
  approvalStatus: 'pending',
  members: [],
  comments: [],
);

void main() {
  const mapper = DioExceptionMapper();

  ResearchRepositoryImpl createRepository(_CreateResearchCallback callback) {
    return ResearchRepositoryImpl(
      _FakeResearchRemoteDataSource(callback),
      mapper,
    );
  }

  group('ResearchRepositoryImpl.createResearch', () {
    test('forwards request and returns created research', () async {
      ResearchRegistrationRequest? capturedRequest;
      final repository = createRepository(({required request}) async {
        capturedRequest = request;
        return _research;
      });

      final result = await repository.createResearch(request: _request);

      expect(capturedRequest, same(_request));
      expect(result, same(_research));
    });

    test('maps connection errors to NetworkException', () {
      final repository = createRepository(({required request}) {
        throw _dioError(DioExceptionType.connectionTimeout);
      });

      expect(
        () => repository.createResearch(request: _request),
        throwsA(isA<NetworkException>()),
      );
    });

    test('preserves backend validation messages', () {
      final repository = createRepository(({required request}) {
        throw _dioError(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: const {'message': 'Sinh viên không đủ điều kiện đăng ký.'},
        );
      });

      expect(
        () => repository.createResearch(request: _request),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.message,
            'message',
            'Sinh viên không đủ điều kiện đăng ký.',
          ),
        ),
      );
    });

    test('maps malformed research responses to UnexpectedException', () {
      final repository = createRepository(({required request}) {
        throw const FormatException('bad research json');
      });

      expect(
        () => repository.createResearch(request: _request),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu đăng ký nghiên cứu khoa học không hợp lệ.',
          ),
        ),
      );
    });
  });
}

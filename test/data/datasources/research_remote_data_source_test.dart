import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/research_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';

void main() {
  const request = ResearchRegistrationRequest(
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
    guiderId: 'lecturer-01',
    members: [ResearchRegistrationMemberRequest(memberId: 'B23DCCN002')],
  );

  Map<String, dynamic> researchJson({
    String id = 'research-ref-01',
    String researchId = 'RESEARCH-01',
  }) {
    return {
      '_id': id,
      'userId': 'user-01',
      'researchId': researchId,
      'type': 'student',
      'level': 'Cấp trường',
      'researchTopic': request.researchTopic,
      'keyword': request.keyword,
      'outcome': request.outcome,
      'description': request.description,
      'researchNecessity': request.researchNecessity,
      'nationalOverview': request.nationalOverview,
      'internationalOverview': request.internationalOverview,
      'yearRef': {
        '_id': 'year-01',
        'code': '2025-2026',
        'name': 'Năm học 2025-2026',
      },
      'approvalStatus': 'pending',
      'members': [
        {
          'userId': 'user-01',
          'memberId': 'B23DCCN001',
          'memberName': 'Nguyễn Văn A',
          'role': 'Leader',
        },
      ],
      'guider': {
        'lecturerRef': 'lecturer-ref-01',
        'lecturerId': 'lecturer-01',
        'lecturerName': 'Trần Văn B',
      },
      'comments': const [],
    };
  }

  group('ResearchRemoteDataSource.getUserResearches', () {
    test('gets researches using year and type filters', () async {
      RequestOptions? capturedRequest;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedRequest = options;
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': [researchJson()],
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ResearchRemoteDataSource(dio);

      final researches = await dataSource.getUserResearches(
        yearId: 'year-01',
        type: 'student',
      );

      expect(capturedRequest!.method, 'GET');
      expect(capturedRequest!.path, '/researches/user');
      expect(capturedRequest!.queryParameters, {
        'yearId': 'year-01',
        'type': 'student',
      });
      expect(capturedRequest!.extra[requiresBearerAuthKey], isTrue);
      expect(researches, hasLength(1));
      expect(researches.single.id, 'research-ref-01');
      expect(researches.single.yearId, 'year-01');
      expect(researches.single.leader?.memberId, 'B23DCCN001');
      expect(researches.single.guider?.lecturerId, 'lecturer-01');
    });
  });

  group('ResearchRemoteDataSource submission', () {
    test('posts registration payload and parses created research', () async {
      RequestOptions? capturedRequest;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedRequest = options;
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'data': {'research': researchJson()},
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ResearchRemoteDataSource(dio);

      final research = await dataSource.createResearch(request: request);

      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.path, '/researches');
      expect(capturedRequest!.data, request.toJson());
      expect(capturedRequest!.extra[requiresBearerAuthKey], isTrue);
      expect(research.researchId, 'RESEARCH-01');
      expect(research.researchTopic, request.researchTopic);
    });

    test('puts revised payload using encoded research id', () async {
      RequestOptions? capturedRequest;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              capturedRequest = options;
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {
                      'research': researchJson(researchId: 'RESEARCH/01'),
                    },
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ResearchRemoteDataSource(dio);

      final research = await dataSource.updateResearch(
        researchId: 'RESEARCH/01',
        request: request,
      );

      expect(capturedRequest!.method, 'PUT');
      expect(capturedRequest!.path, '/researches/RESEARCH%2F01');
      expect(capturedRequest!.data, request.toJson());
      expect(capturedRequest!.extra[requiresBearerAuthKey], isTrue);
      expect(research.researchId, 'RESEARCH/01');
    });

    test('throws FormatException when response has no research identity', () {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'data': {
                      'research': {'researchTopic': 'Thiếu định danh'},
                    },
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ResearchRemoteDataSource(dio);

      expect(
        () => dataSource.createResearch(request: request),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

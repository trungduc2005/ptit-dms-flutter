import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/research_seminar_committee_remote_data_source.dart';

void main() {
  Dio createStubDio(
    Object? Function(RequestOptions options) responseData, {
    void Function(RequestOptions options)? capture,
  }) {
    return Dio(BaseOptions(baseUrl: 'https://example.test/api'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capture?.call(options);
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: responseData(options),
              ),
            );
          },
        ),
      );
  }

  Map<String, Object?> validResponse({Object? committee}) {
    return {
      'researches': [
        {
          'researchId': 'RESEARCH-01',
          'researchTopic': 'Ứng dụng trí tuệ nhân tạo',
        },
      ],
      'committee':
          committee ??
          {
            'committeeId': 'COMMITTEE-01',
            'name': 'Hội đồng hội thảo số 1',
            'time': '08:30',
            'date': '2026-08-10',
            'location': 'Phòng 101',
            'members': [
              {
                'memberId': 'LECTURER-01',
                'memberName': 'Nguyễn Văn A',
                'department': 'Khoa Công nghệ thông tin',
                'role': 'Chủ tịch',
                'avatarUrl': 'https://example.test/avatar.png',
              },
            ],
            'research': {
              'researchId': 'RESEARCH-01',
              'researchTopic': 'Ứng dụng trí tuệ nhân tạo',
              'presentationOrder': 2,
              'reviewerName': 'Trần Văn B',
            },
          },
    };
  }

  group('ResearchSeminarCommitteeRemoteDataSource', () {
    test('sends normalized query and parses committee response', () async {
      RequestOptions? captured;
      final dataSource = ResearchSeminarCommitteeRemoteDataSource(
        createStubDio(
          (_) => validResponse(),
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.getMyCommittee(
        yearId: ' YEAR-01 ',
        researchId: ' RESEARCH-01 ',
      );

      expect(captured!.method, 'GET');
      expect(
        captured!.path,
        '/researches/committees/my/presentationResearchCommittee',
      );
      expect(captured!.queryParameters, {
        'yearId': 'YEAR-01',
        'researchId': 'RESEARCH-01',
      });
      expect(captured!.extra[requiresBearerAuthKey], isTrue);

      expect(result.researches, hasLength(1));
      expect(result.researches.single.researchId, 'RESEARCH-01');
      expect(
        result.researches.single.researchTopic,
        'Ứng dụng trí tuệ nhân tạo',
      );

      final committee = result.committee!;
      expect(committee.committeeId, 'COMMITTEE-01');
      expect(committee.name, 'Hội đồng hội thảo số 1');
      expect(committee.time, '08:30');
      expect(committee.date, DateTime.parse('2026-08-10'));
      expect(committee.location, 'Phòng 101');
      expect(committee.members.single.memberId, 'LECTURER-01');
      expect(committee.members.single.memberName, 'Nguyễn Văn A');
      expect(committee.members.single.department, 'Khoa Công nghệ thông tin');
      expect(committee.members.single.role, 'Chủ tịch');
      expect(
        committee.members.single.avatarUrl,
        'https://example.test/avatar.png',
      );
      expect(committee.research.researchId, 'RESEARCH-01');
      expect(committee.research.presentationOrder, 2);
      expect(committee.research.reviewerName, 'Trần Văn B');
    });

    test(
      'omits blank optional research id and parses null committee',
      () async {
        RequestOptions? captured;
        final dataSource = ResearchSeminarCommitteeRemoteDataSource(
          createStubDio(
            (_) => {'researches': <Object?>[], 'committee': null},
            capture: (options) => captured = options,
          ),
        );

        final result = await dataSource.getMyCommittee(
          yearId: 'YEAR-01',
          researchId: '   ',
        );

        expect(captured!.queryParameters, {'yearId': 'YEAR-01'});
        expect(result.researches, isEmpty);
        expect(result.committee, isNull);
      },
    );

    test('rejects blank year before sending request', () async {
      var requestWasSent = false;
      final dataSource = ResearchSeminarCommitteeRemoteDataSource(
        createStubDio(
          (_) => validResponse(),
          capture: (_) => requestWasSent = true,
        ),
      );

      await expectLater(
        dataSource.getMyCommittee(yearId: '   '),
        throwsA(isA<FormatException>()),
      );
      expect(requestWasSent, isFalse);
    });

    test('rejects non-object response', () async {
      final dataSource = ResearchSeminarCommitteeRemoteDataSource(
        createStubDio((_) => <Object?>[]),
      );

      await expectLater(
        dataSource.getMyCommittee(yearId: 'YEAR-01'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed nested committee data', () async {
      final dataSource = ResearchSeminarCommitteeRemoteDataSource(
        createStubDio(
          (_) => validResponse(
            committee: {
              'committeeId': 'COMMITTEE-01',
              'name': 'Hội đồng',
              'members': 'invalid',
              'research': <String, Object?>{},
            },
          ),
        ),
      );

      await expectLater(
        dataSource.getMyCommittee(yearId: 'YEAR-01'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/research_final_committee_remote_data_source.dart';

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

  Map<String, Object?> validResponse() {
    return {
      'researches': [
        {
          'researchId': 'RESEARCH-01',
          'researchTopic': 'Ứng dụng trí tuệ nhân tạo',
        },
      ],
      'committee': {
        'committeeId': 'COMMITTEE-01',
        'name': 'Hội đồng nghiệm thu số 1',
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

  group('ResearchFinalCommitteeRemoteDataSource', () {
    test('sends normalized query and parses final committee', () async {
      RequestOptions? captured;
      final dataSource = ResearchFinalCommitteeRemoteDataSource(
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
        '/researches/committees/my/finalResearchCommittee',
      );
      expect(captured!.queryParameters, {
        'yearId': 'YEAR-01',
        'researchId': 'RESEARCH-01',
      });
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(result.researches.single.researchId, 'RESEARCH-01');
      expect(result.committee!.committeeId, 'COMMITTEE-01');
      expect(result.committee!.name, 'Hội đồng nghiệm thu số 1');
      expect(result.committee!.date, DateTime.parse('2026-08-10'));
      expect(result.committee!.members.single.role, 'Chủ tịch');
      expect(result.committee!.research.presentationOrder, 2);
      expect(result.committee!.research.reviewerName, 'Trần Văn B');
    });

    test('omits blank research id and parses null committee', () async {
      RequestOptions? captured;
      final dataSource = ResearchFinalCommitteeRemoteDataSource(
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
    });

    test('rejects blank year before sending request', () async {
      var requestWasSent = false;
      final dataSource = ResearchFinalCommitteeRemoteDataSource(
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

    test('rejects malformed response', () async {
      final dataSource = ResearchFinalCommitteeRemoteDataSource(
        createStubDio((_) => <Object?>[]),
      );

      await expectLater(
        dataSource.getMyCommittee(yearId: 'YEAR-01'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

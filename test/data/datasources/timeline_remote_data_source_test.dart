import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/timeline_remote_data_source.dart';

void main() {
  group('TimelineRemoteDataSource.getResearchTimelines', () {
    test(
      'gọi đúng endpoint nghiên cứu với năm học và đối tượng sinh viên',
      () async {
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
                      'data': [
                        {
                          '_id': 'timeline-1',
                          'name': 'Đăng ký nghiên cứu khoa học',
                          'type': 'researchRegistration',
                          'startTime': '2026-08-01T08:00:00.000',
                          'endTime': '2026-08-31T17:00:00.000',
                        },
                      ],
                    },
                  ),
                );
              },
            ),
          );
        final dataSource = TimelineRemoteDataSource(dio);

        final timelines = await dataSource.getResearchTimelines(
          academicYearId: 'year-1',
        );

        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.path, '/researches/timelines');
        expect(capturedRequest!.queryParameters, {
          'yearId': 'year-1',
          'target': 'student',
        });
        expect(capturedRequest!.extra[requiresBearerAuthKey], isTrue);
        expect(timelines, hasLength(1));
        expect(timelines.single.id, 'timeline-1');
        expect(timelines.single.name, 'Đăng ký nghiên cứu khoa học');
        expect(timelines.single.type, 'researchRegistration');
        expect(timelines.single.startTime, DateTime(2026, 8, 1, 8));
        expect(timelines.single.endTime, DateTime(2026, 8, 31, 17));
      },
    );
  });
}

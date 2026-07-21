import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_progress_report_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_progress_report_request.dart';

void main() {
  const request = ProjectProgressReportRequest(
    projectId: 'PROJECT-01',
    key: 'week-01',
    brief: 'Hoàn thành phân tích yêu cầu',
    difficulty: 'Thiếu dữ liệu kiểm thử',
    expectation: 'Hoàn thành giao diện',
    link: 'https://example.test/report',
    academicYearId: 'year-01',
  );

  Map<String, dynamic> reportJson({bool includeReplies = true}) {
    return {
      '_id': 'report-01',
      'projectRef': {'_id': 'project-object-01'},
      'projectId': 'PROJECT-01',
      'key': 'week-01',
      'brief': 'Hoàn thành phân tích yêu cầu',
      'difficulty': 'Thiếu dữ liệu kiểm thử',
      'expectation': 'Hoàn thành giao diện',
      'link': 'https://example.test/report',
      if (includeReplies)
        'replies': [
          {
            'key': 'week-01',
            'brief': 'Hoàn thành phân tích yêu cầu',
            'reply': 'Cần bổ sung kiểm thử',
            'createdAt': '2026-07-17T08:00:00.000Z',
          },
        ],
      'createdAt': '2026-07-17T07:00:00.000Z',
      'updatedAt': '2026-07-17T07:30:00.000Z',
    };
  }

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

  group('ProjectProgressReportRemoteDataSource', () {
    test('gets and parses reports using the project MongoDB id', () async {
      RequestOptions? captured;
      final dataSource = ProjectProgressReportRemoteDataSource(
        createStubDio(
          (_) => [reportJson()],
          capture: (options) => captured = options,
        ),
      );

      final reports = await dataSource.getReports(
        projectObjectId: 'project-object-01',
        academicYearId: 'year-01',
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, '/projects/reports/project-object-01');
      expect(captured!.queryParameters, {'academicYearId': 'year-01'});
      expect(reports, hasLength(1));
      expect(reports.single.projectRef, 'project-object-01');
      expect(reports.single.replies.single.content, 'Cần bổ sung kiểm thử');
    });

    test(
      'gets and parses flattened replies using the business project id',
      () async {
        RequestOptions? captured;
        final dataSource = ProjectProgressReportRemoteDataSource(
          createStubDio(
            (_) => [
              {
                'key': 'week-01',
                'brief': 'Hoàn thành phân tích yêu cầu',
                'reply': 'Cần bổ sung kiểm thử',
              },
            ],
            capture: (options) => captured = options,
          ),
        );

        final replies = await dataSource.getReplies(
          projectId: 'PROJECT-01',
          academicYearId: 'year-01',
        );

        expect(captured!.method, 'GET');
        expect(captured!.path, '/projects/reports/replies/PROJECT-01');
        expect(captured!.queryParameters, {'academicYearId': 'year-01'});
        expect(replies.single.key, 'week-01');
        expect(replies.single.content, 'Cần bổ sung kiểm thử');
      },
    );

    test(
      'creates a report and unwraps projectReport from the response',
      () async {
        RequestOptions? captured;
        final dataSource = ProjectProgressReportRemoteDataSource(
          createStubDio(
            (_) => {'message': 'Thành công', 'projectReport': reportJson()},
            capture: (options) => captured = options,
          ),
        );

        final report = await dataSource.createReport(request: request);

        expect(captured!.method, 'POST');
        expect(captured!.path, '/projects/reports');
        expect(captured!.data, request.toJson());
        expect(report.id, 'report-01');
        expect(report.key, 'week-01');
      },
    );

    test('updates a report and parses the direct response object', () async {
      RequestOptions? captured;
      final dataSource = ProjectProgressReportRemoteDataSource(
        createStubDio(
          (_) => reportJson(includeReplies: false),
          capture: (options) => captured = options,
        ),
      );

      final report = await dataSource.updateReport(request: request);

      expect(captured!.method, 'PUT');
      expect(captured!.path, '/projects/reports');
      expect(captured!.data, request.toJson());
      expect(report.id, 'report-01');
      expect(report.replies, isEmpty);
    });

    test('throws FormatException when a list response is malformed', () async {
      final dataSource = ProjectProgressReportRemoteDataSource(
        createStubDio((_) => {'reports': <Object?>[]}),
      );

      expect(
        () => dataSource.getReports(
          projectObjectId: 'project-object-01',
          academicYearId: 'year-01',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'throws FormatException when create response has no projectReport',
      () async {
        final dataSource = ProjectProgressReportRemoteDataSource(
          createStubDio((_) => {'message': 'Thành công'}),
        );

        expect(
          () => dataSource.createReport(request: request),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

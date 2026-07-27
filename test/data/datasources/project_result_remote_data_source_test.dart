import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_result_remote_data_source.dart';

void main() {
  Dio createStubDio(
    Object? responseData, {
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
                data: responseData,
              ),
            );
          },
        ),
      );
  }

  Map<String, dynamic> validResponse() {
    return {
      'projectId': 'project-01',
      'projectName': 'Hệ thống quản lý đồ án',
      'members': [
        {
          '_id': 'result-01',
          'studentId': 'B20DCCN001',
          'userId': {
            'fullName': 'Nguyễn Văn A',
            'avatarUrl': 'https://example.test/avatar.png',
          },
          'classId': {'name': 'D20CQCN01-B'},
          'clos': [
            {
              'cloId': 'clo-01',
              'cloName': 'CLO1',
              'cloDescription': 'Khả năng phân tích yêu cầu',
              'cloWeight': 0.4,
              'average': 8.25,
            },
          ],
          'totalGPA': 8.25,
        },
      ],
    };
  }

  group('ProjectResultRemoteDataSource', () {
    test('requests and parses project CLO results', () async {
      RequestOptions? captured;
      final dataSource = ProjectResultRemoteDataSource(
        createStubDio(
          validResponse(),
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.getProjectResult(projectId: 'project-01');

      expect(captured!.method, 'GET');
      expect(
        captured!.path,
        '/projects/evaluations-result/project-01/clo-results',
      );
      expect(result.projectId, 'project-01');
      expect(result.projectName, 'Hệ thống quản lý đồ án');
      expect(result.isPublished, isTrue);
      expect(result.members.single.studentId, 'B20DCCN001');
      expect(result.members.single.fullName, 'Nguyễn Văn A');
      expect(result.members.single.className, 'D20CQCN01-B');
      expect(result.members.single.totalGpa, 8.25);
      expect(result.members.single.clos.single.cloName, 'CLO1');
      expect(result.members.single.clos.single.cloWeight, 0.4);
    });

    test('parses an unpublished result with empty members', () async {
      final response = validResponse()..['members'] = <Object?>[];
      final dataSource = ProjectResultRemoteDataSource(createStubDio(response));

      final result = await dataSource.getProjectResult(projectId: 'project-01');

      expect(result.members, isEmpty);
      expect(result.isPublished, isFalse);
    });

    test('throws FormatException when response is not an object', () async {
      final dataSource = ProjectResultRemoteDataSource(
        createStubDio(<Object?>[]),
      );

      expect(
        () => dataSource.getProjectResult(projectId: 'project-01'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when members is not a list', () async {
      final response = validResponse()..['members'] = 'invalid';
      final dataSource = ProjectResultRemoteDataSource(createStubDio(response));

      expect(
        () => dataSource.getProjectResult(projectId: 'project-01'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

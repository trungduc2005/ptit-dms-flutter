import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_remote_data_source.dart';

void main() {
  group('ProjectRemoteDataSource.checkProject', () {
    test(
      'returns null without requesting details when not registered',
      () async {
        final requestedPaths = <String>[];
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                requestedPaths.add(options.path);
                handler.resolve(
                  Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 200,
                    data: {'register': false},
                  ),
                );
              },
            ),
          );
        final dataSource = ProjectRemoteDataSource(dio);

        final project = await dataSource.checkProject(
          academicYearId: 'year-01',
          studentId: 'B23DCCN001',
        );

        expect(project, isNull);
        expect(requestedPaths, ['/projects/check-project']);
      },
    );

    test('loads and parses project details when already registered', () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);

              if (options.path == '/projects/check-project') {
                handler.resolve(
                  Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'data': {'register': true},
                    },
                  ),
                );
                return;
              }

              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {
                      'project': {
                        '_id': 'mongo-project-01',
                        'projectId': 'PROJECT-01',
                        'projectName': 'Hệ thống quản lý đồ án',
                        'field': 'Công nghệ phần mềm',
                        'period': 'Đợt 1',
                        'keyword': 'Flutter, DMS',
                        'description': 'Ứng dụng quản lý đồ án',
                        'outcome': 'Ứng dụng di động',
                        'status': 'project_needs_revision',
                        'guiderApprovalStatus': 'approved',
                        'academicYearRef': 'year-01',
                        'members': [
                          {
                            'studentRef': 'student-ref-01',
                            'studentId': 'B23DCCN001',
                            'studentName': 'Nguyễn Văn A',
                            'role': 'Leader',
                            'approvalStatus': 'approved',
                          },
                        ],
                      },
                    },
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      final project = await dataSource.checkProject(
        academicYearId: 'year-01',
        studentId: 'B23DCCN001',
      );

      expect(project, isNotNull);
      expect(project!.id, 'mongo-project-01');
      expect(project.projectName, 'Hệ thống quản lý đồ án');
      expect(project.guiderApprovalStatus, 'approved');
      expect(project.leader?.studentId, 'B23DCCN001');
      expect(requests, hasLength(2));
      expect(requests[0].path, '/projects/check-project');
      expect(requests[0].queryParameters['academicYearId'], 'year-01');
      expect(requests[1].path, '/projects/B23DCCN001');
      expect(requests[1].queryParameters['academicYearId'], 'year-01');
    });
  });

  group('ProjectRemoteDataSource membership response', () {
    test('sends approval to the encoded membership endpoint', () async {
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
                  data: const {'success': true},
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      await dataSource.approveProjectMembership(
        projectId: 'PROJECT/01',
        studentRef: 'student ref/01',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(
        capturedRequest!.path,
        '/projects/PROJECT%2F01/members/student%20ref%2F01/approve',
      );
      expect(capturedRequest!.data, isNull);
    });

    test('sends rejection reason to the encoded membership endpoint', () async {
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
                  data: const {'success': true},
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      await dataSource.rejectProjectMembership(
        projectId: 'PROJECT/01',
        studentRef: 'student ref/01',
        reason: 'Đã tham gia nhóm khác',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(
        capturedRequest!.path,
        '/projects/PROJECT%2F01/members/student%20ref%2F01/reject',
      );
      expect(capturedRequest!.data, {'reason': 'Đã tham gia nhóm khác'});
    });

    test('omits rejection body when no reason is provided', () async {
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
                  data: const {'success': true},
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      await dataSource.rejectProjectMembership(
        projectId: 'PROJECT-01',
        studentRef: 'student-ref-01',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.data, isNull);
    });
  });
}

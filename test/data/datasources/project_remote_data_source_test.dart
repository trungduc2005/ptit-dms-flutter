import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

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

  group('ProjectRemoteDataSource registration options', () {
    test('loads project periods with the project type filter', () async {
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
                      {'_id': 'period-01', 'name': 'Đợt 1'},
                      {'_id': 'period-empty', 'name': '  '},
                    ],
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      final periods = await dataSource.getProjectPeriods();

      expect(capturedRequest!.path, '/periods');
      expect(capturedRequest!.queryParameters, {'type': 'project'});
      expect(periods, hasLength(1));
      expect(periods.single.id, 'period-01');
      expect(periods.single.name, 'Đợt 1');
    });

    test('loads guiders for the selected academic year', () async {
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
                        'lecturerId': 'lecturer-01',
                        'userId': {
                          'fullName': 'Nguyễn Văn A',
                          'departmentId': {'name': 'Công nghệ thông tin'},
                        },
                        'limit': 5,
                        'usedSlot': 2,
                      },
                    ],
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      final guiders = await dataSource.getProjectGuiders(
        academicYearId: 'year-01',
      );

      expect(capturedRequest!.path, '/lecturers/guiders');
      expect(capturedRequest!.queryParameters, {'academicYearId': 'year-01'});
      expect(guiders.single.lecturerId, 'lecturer-01');
      expect(guiders.single.fullName, 'Nguyễn Văn A');
      expect(guiders.single.remainingSlot, 3);
    });
  });

  group('ProjectRemoteDataSource registration submission', () {
    const request = ProjectRegistrationRequest(
      academicYearId: 'year-01',
      field: 'Công nghệ phần mềm',
      period: 'Đợt 1',
      projectName: 'Hệ thống quản lý nghiên cứu khoa học',
      keyword: 'Flutter, DMS',
      description: 'Ứng dụng dành cho sinh viên',
      outcome: 'Ứng dụng di động',
      guiderId: 'lecturer-01',
      guiderName: 'Nguyễn Văn A',
      members: [
        {'studentId': 'B23DCCN002'},
      ],
    );

    Map<String, dynamic> projectResponse() {
      return {
        'data': {
          'project': {
            '_id': 'project-ref-01',
            'projectId': 'PROJECT-01',
            'projectName': 'Hệ thống quản lý nghiên cứu khoa học',
            'field': 'Công nghệ phần mềm',
            'period': 'Đợt 1',
            'keyword': 'Flutter, DMS',
            'description': 'Ứng dụng dành cho sinh viên',
            'outcome': 'Ứng dụng di động',
            'status': 'pending',
            'academicYearRef': 'year-01',
            'members': const [],
          },
        },
      };
    }

    test('posts the student registration payload and parses project', () async {
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
                  data: projectResponse(),
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      final project = await dataSource.registerProject(request: request);

      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.path, '/projects');
      expect(capturedRequest!.data, request.toJson());
      expect(project.id, 'project-ref-01');
      expect(project.projectName, request.projectName);
    });

    test('puts the revised registration payload and parses project', () async {
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
                  data: projectResponse(),
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      final project = await dataSource.updateProject(request: request);

      expect(capturedRequest!.method, 'PUT');
      expect(capturedRequest!.path, '/projects');
      expect(capturedRequest!.data, request.toJson());
      expect(project.projectId, 'PROJECT-01');
    });

    test('rejects a registration response without a project payload', () {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 201,
                  data: const {
                    'success': true,
                    'message': 'Đăng ký thành công',
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      expect(
        () => dataSource.registerProject(request: request),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a registration project without an identity', () {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 201,
                  data: const {
                    'project': {
                      'projectName': 'Hệ thống không có mã định danh',
                    },
                  },
                ),
              );
            },
          ),
        );
      final dataSource = ProjectRemoteDataSource(dio);

      expect(
        () => dataSource.registerProject(request: request),
        throwsA(isA<FormatException>()),
      );
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

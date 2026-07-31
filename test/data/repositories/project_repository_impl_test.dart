import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/project_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/project.dart';
import 'package:ptit_dms_flutter/domain/entities/project_registration_request.dart';

typedef _RegisterProjectCallback =
    Future<Project> Function({required ProjectRegistrationRequest request});

class _FakeProjectRemoteDataSource extends Fake
    implements ProjectRemoteDataSource {
  _FakeProjectRemoteDataSource(this._registerCallback);

  final _RegisterProjectCallback _registerCallback;

  @override
  Future<Project> registerProject({
    required ProjectRegistrationRequest request,
  }) {
    return _registerCallback(request: request);
  }
}

DioException _dioError(DioExceptionType type, {int? statusCode, Object? data}) {
  final requestOptions = RequestOptions(path: '/projects');
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

const _request = ProjectRegistrationRequest(
  academicYearId: 'year-01',
  field: 'Công nghệ phần mềm',
  period: 'Đợt 1',
  projectName: 'Hệ thống quản lý nghiên cứu khoa học',
  keyword: 'Flutter, DMS',
  description: 'Ứng dụng dành cho sinh viên',
  outcome: 'Ứng dụng di động',
  members: [
    {'studentId': 'B23DCCN002'},
  ],
);

const _project = Project(
  id: 'project-ref-01',
  projectId: 'PROJECT-01',
  projectName: 'Hệ thống quản lý nghiên cứu khoa học',
  field: 'Công nghệ phần mềm',
  period: 'Đợt 1',
  keyword: 'Flutter, DMS',
  description: 'Ứng dụng dành cho sinh viên',
  outcome: 'Ứng dụng di động',
  status: 'pending',
  guiderReceptionStatus: 'processing',
  guiderApprovalStatus: 'processing',
  memberApprovalStatus: 'waiting_members',
  academicYearRef: 'year-01',
  members: [],
  memberApprovalHistory: [],
);

void main() {
  const mapper = DioExceptionMapper();

  ProjectRepositoryImpl createRepository(_RegisterProjectCallback callback) {
    return ProjectRepositoryImpl(
      _FakeProjectRemoteDataSource(callback),
      mapper,
    );
  }

  group('ProjectRepositoryImpl.registerProject', () {
    test(
      'forwards the student request and returns the created project',
      () async {
        ProjectRegistrationRequest? capturedRequest;
        final repository = createRepository(({required request}) async {
          capturedRequest = request;
          return _project;
        });

        final result = await repository.registerProject(request: _request);

        expect(capturedRequest, same(_request));
        expect(result, same(_project));
      },
    );

    test('maps connection errors to NetworkException', () {
      final repository = createRepository(({required request}) {
        throw _dioError(DioExceptionType.connectionTimeout);
      });

      expect(
        () => repository.registerProject(request: _request),
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
        () => repository.registerProject(request: _request),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.message,
            'message',
            'Sinh viên không đủ điều kiện đăng ký.',
          ),
        ),
      );
    });

    test('maps malformed project responses to UnexpectedException', () {
      final repository = createRepository(({required request}) {
        throw const FormatException('bad project json');
      });

      expect(
        () => repository.registerProject(request: _request),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu đăng ký đồ án không hợp lệ.',
          ),
        ),
      );
    });
  });
}

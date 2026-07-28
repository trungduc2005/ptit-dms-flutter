import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_result_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/project_result_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/project_result.dart';

typedef _GetProjectResultCallback =
    Future<ProjectResult> Function({
      required String projectId,
      required String academicYearId,
    });

class _FakeProjectResultDataSource extends Fake
    implements ProjectResultRemoteDataSource {
  _FakeProjectResultDataSource(this._callback);

  final _GetProjectResultCallback _callback;

  @override
  Future<ProjectResult> getProjectResult({
    required String projectId,
    required String academicYearId,
  }) {
    return _callback(projectId: projectId, academicYearId: academicYearId);
  }
}

DioException _dioError(DioExceptionType type, {int? statusCode}) {
  return DioException(
    requestOptions: RequestOptions(),
    type: type,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: RequestOptions(),
            statusCode: statusCode,
          ),
  );
}

const _projectResult = ProjectResult(
  projectId: 'project-01',
  projectName: 'Hệ thống quản lý đồ án',
  members: [
    ProjectResultMember(
      studentId: 'B20DCCN001',
      fullName: 'Nguyễn Văn A',
      clos: [
        ProjectCloResult(
          cloId: 'clo-01',
          cloName: 'CLO1',
          cloDescription: 'Khả năng phân tích yêu cầu',
          cloWeight: 0.4,
          average: 8.25,
        ),
      ],
      totalGpa: 8.25,
    ),
  ],
);

void main() {
  const mapper = DioExceptionMapper();

  ProjectResultRepositoryImpl createRepository(
    _GetProjectResultCallback callback,
  ) {
    return ProjectResultRepositoryImpl(
      _FakeProjectResultDataSource(callback),
      mapper,
    );
  }

  group('ProjectResultRepositoryImpl.getProjectResult', () {
    test('returns result and forwards project and academic year ids', () async {
      String? capturedProjectId;
      String? capturedAcademicYearId;
      final repository = createRepository(({
        required projectId,
        required academicYearId,
      }) async {
        capturedProjectId = projectId;
        capturedAcademicYearId = academicYearId;
        return _projectResult;
      });

      final result = await repository.getProjectResult(
        projectId: 'project-01',
        academicYearId: 'academic-year-01',
      );

      expect(result, same(_projectResult));
      expect(capturedProjectId, 'project-01');
      expect(capturedAcademicYearId, 'academic-year-01');
    });

    test('maps connection DioException to NetworkException', () {
      final repository = createRepository(({
        required projectId,
        required academicYearId,
      }) {
        throw _dioError(DioExceptionType.connectionTimeout);
      });

      expect(
        () => repository.getProjectResult(
          projectId: 'project-01',
          academicYearId: 'academic-year-01',
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps unauthorized DioException to UnauthorizedException', () {
      final repository = createRepository(({
        required projectId,
        required academicYearId,
      }) {
        throw _dioError(DioExceptionType.badResponse, statusCode: 401);
      });

      expect(
        () => repository.getProjectResult(
          projectId: 'project-01',
          academicYearId: 'academic-year-01',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('maps malformed response to UnexpectedException', () {
      final repository = createRepository(({
        required projectId,
        required academicYearId,
      }) {
        throw const FormatException('bad json');
      });

      expect(
        () => repository.getProjectResult(
          projectId: 'project-01',
          academicYearId: 'academic-year-01',
        ),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu kết quả đồ án tốt nghiệp không hợp lệ.',
          ),
        ),
      );
    });
  });
}

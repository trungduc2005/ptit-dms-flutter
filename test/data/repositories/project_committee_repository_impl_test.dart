import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/project_committee_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/project_committee_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/project_committee.dart';

typedef _GetCommitteeCallback =
    Future<ProjectCommittee> Function({required String academicYearId});

class _FakeProjectCommitteeDataSource extends Fake
    implements ProjectCommitteeRemoteDataSource {
  _FakeProjectCommitteeDataSource(this._callback);

  final _GetCommitteeCallback _callback;

  @override
  Future<ProjectCommittee> getMyProjectCommittee({
    required String academicYearId,
  }) {
    return _callback(academicYearId: academicYearId);
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

const _committee = ProjectCommittee(
  committeeId: 'committee-01',
  name: 'Hội đồng 1',
  members: [
    ProjectCommitteeMember(
      memberId: 'lecturer-01',
      memberName: 'Nguyễn Văn A',
      department: 'Công nghệ thông tin',
      role: 'Chủ tịch',
    ),
  ],
  academicYear: '2025-2026',
  project: ProjectCommitteeProject(
    id: 'project-ref-01',
    projectId: 'PROJECT-01',
    projectName: 'Hệ thống quản lý đồ án',
    members: [
      ProjectCommitteeStudent(
        studentRef: 'student-ref-01',
        studentId: 'B20DCCN001',
        studentName: 'Trần Văn B',
        role: 'leader',
      ),
    ],
    presentationOrder: 1,
  ),
);

void main() {
  const mapper = DioExceptionMapper();

  ProjectCommitteeRepositoryImpl createRepository(
    _GetCommitteeCallback callback,
  ) {
    return ProjectCommitteeRepositoryImpl(
      _FakeProjectCommitteeDataSource(callback),
      mapper,
    );
  }

  group('ProjectCommitteeRepositoryImpl.getMyProjectCommittee', () {
    test('returns committee and forwards academic year id', () async {
      String? capturedAcademicYearId;
      final repository = createRepository(({required academicYearId}) async {
        capturedAcademicYearId = academicYearId;
        return _committee;
      });

      final result = await repository.getMyProjectCommittee(
        academicYearId: 'year-01',
      );

      expect(result, same(_committee));
      expect(capturedAcademicYearId, 'year-01');
    });

    test('maps connection DioException to NetworkException', () {
      final repository = createRepository(({required academicYearId}) {
        throw _dioError(DioExceptionType.connectionTimeout);
      });

      expect(
        () => repository.getMyProjectCommittee(academicYearId: 'year-01'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps unauthorized DioException to UnauthorizedException', () {
      final repository = createRepository(({required academicYearId}) {
        throw _dioError(DioExceptionType.badResponse, statusCode: 401);
      });

      expect(
        () => repository.getMyProjectCommittee(academicYearId: 'year-01'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('maps malformed response to UnexpectedException', () {
      final repository = createRepository(({required academicYearId}) {
        throw const FormatException('bad json');
      });

      expect(
        () => repository.getMyProjectCommittee(academicYearId: 'year-01'),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu hội đồng đồ án không hợp lệ.',
          ),
        ),
      );
    });
  });
}

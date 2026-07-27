import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/data/datasources/project_committee_remote_data_source.dart';

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
      'committeeId': 'committee-01',
      'name': 'Hội đồng 1',
      'members': [
        {
          'memberId': 'lecturer-01',
          'memberName': 'Nguyễn Văn A',
          'department': 'Công nghệ thông tin',
          'role': 'Chủ tịch',
          'avatarUrl': 'https://example.test/avatar.png',
        },
      ],
      'time': '08:00',
      'date': '2026-08-01T00:00:00.000Z',
      'location': 'Phòng 101',
      'academicYear': '2025-2026',
      'project': {
        '_id': 'project-ref-01',
        'projectId': 'PROJECT-01',
        'projectName': 'Hệ thống quản lý đồ án',
        'members': [
          {
            'studentRef': 'student-ref-01',
            'studentId': 'B20DCCN001',
            'studentName': 'Trần Văn B',
            'classId': 'D20CQCN01-B',
            'cohort': '2020',
            'role': 'leader',
            'avatar': 'https://example.test/student.png',
          },
        ],
        'guiderName': 'Lê Văn C',
        'guiderId': 'GV001',
        'reviewerName': 'Phạm Văn D',
        'reviewerId': 'GV002',
        'presentationOrder': 2,
      },
    };
  }

  group('ProjectCommitteeRemoteDataSource', () {
    test('requests and parses the current student committee', () async {
      RequestOptions? captured;
      final dataSource = ProjectCommitteeRemoteDataSource(
        createStubDio(
          validResponse(),
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.getMyProjectCommittee(
        academicYearId: 'year-01',
      );

      expect(captured!.method, 'GET');
      expect(captured!.path, '/projects/committees/me');
      expect(captured!.queryParameters, {'academicYearId': 'year-01'});
      expect(result.committeeId, 'committee-01');
      expect(result.name, 'Hội đồng 1');
      expect(result.date, DateTime.parse('2026-08-01T00:00:00.000Z'));
      expect(result.members.single.memberName, 'Nguyễn Văn A');
      expect(result.project.projectId, 'PROJECT-01');
      expect(result.project.presentationOrder, 2);
      expect(result.project.members.single.studentId, 'B20DCCN001');
      expect(
        result.project.members.single.avatarUrl,
        'https://example.test/student.png',
      );
    });

    test('throws FormatException when response is not an object', () async {
      final dataSource = ProjectCommitteeRemoteDataSource(
        createStubDio(<Object?>[]),
      );

      expect(
        () => dataSource.getMyProjectCommittee(academicYearId: 'year-01'),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'throws FormatException when committee members is not a list',
      () async {
        final response = validResponse()..['members'] = 'invalid';
        final dataSource = ProjectCommitteeRemoteDataSource(
          createStubDio(response),
        );

        expect(
          () => dataSource.getMyProjectCommittee(academicYearId: 'year-01'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

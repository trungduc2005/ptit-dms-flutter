import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/core/error/dio_exception_mapper.dart';
import 'package:ptit_dms_flutter/data/datasources/student_profile_remote_data_source.dart';
import 'package:ptit_dms_flutter/data/repositories/student_profile_repository_impl.dart';
import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';

class _FakeStudentProfileRemoteDataSource
    extends StudentProfileRemoteDataSource {
  _FakeStudentProfileRemoteDataSource({
    this.getProfileCallback,
    this.updateProfileCallback,
    this.uploadAvatarCallback,
  }) : super(Dio());

  final Future<StudentProfile> Function()? getProfileCallback;
  final Future<StudentProfile> Function(StudentProfileUpdateRequest request)?
  updateProfileCallback;
  final Future<AvatarUploadResult> Function(String filePath)?
  uploadAvatarCallback;

  @override
  Future<StudentProfile> getProfile() {
    return getProfileCallback!.call();
  }

  @override
  Future<StudentProfile> updateProfile({
    required StudentProfileUpdateRequest request,
  }) {
    return updateProfileCallback!.call(request);
  }

  @override
  Future<AvatarUploadResult> uploadAvatar({required String filePath}) {
    return uploadAvatarCallback!.call(filePath);
  }
}

const _profile = StudentProfile(
  id: 'profile-01',
  studentId: 'B21DCCN001',
  cohort: 'D21',
  major: ['Công nghệ thông tin'],
);

const _request = StudentProfileUpdateRequest(email: 'student@ptit.edu.vn');

DioException _dioError({
  required DioExceptionType type,
  int? statusCode,
  Object? data,
}) {
  final options = RequestOptions(path: '/info');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: options,
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  const mapper = DioExceptionMapper();

  StudentProfileRepositoryImpl buildRepository(
    _FakeStudentProfileRemoteDataSource dataSource,
  ) {
    return StudentProfileRepositoryImpl(dataSource, mapper);
  }

  group('StudentProfileRepositoryImpl', () {
    test('getProfile returns parsed profile from data source', () async {
      final repository = buildRepository(
        _FakeStudentProfileRemoteDataSource(
          getProfileCallback: () async => _profile,
        ),
      );

      expect(await repository.getProfile(), _profile);
    });

    test('getProfile maps Dio connection error to NetworkException', () {
      final repository = buildRepository(
        _FakeStudentProfileRemoteDataSource(
          getProfileCallback: () {
            throw _dioError(type: DioExceptionType.connectionTimeout);
          },
        ),
      );

      expect(repository.getProfile, throwsA(isA<NetworkException>()));
    });

    test('getProfile maps FormatException to UnexpectedException', () {
      final repository = buildRepository(
        _FakeStudentProfileRemoteDataSource(
          getProfileCallback: () {
            throw const FormatException('invalid profile');
          },
        ),
      );

      expect(
        repository.getProfile,
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Dữ liệu hồ sơ sinh viên không hợp lệ.',
          ),
        ),
      );
    });

    test(
      'updateProfile forwards the request and returns updated profile',
      () async {
        StudentProfileUpdateRequest? capturedRequest;
        final repository = buildRepository(
          _FakeStudentProfileRemoteDataSource(
            updateProfileCallback: (request) async {
              capturedRequest = request;
              return _profile;
            },
          ),
        );

        final result = await repository.updateProfile(request: _request);

        expect(capturedRequest, _request);
        expect(result, _profile);
      },
    );

    test('updateProfile maps 422 response to ValidationException', () {
      final repository = buildRepository(
        _FakeStudentProfileRemoteDataSource(
          updateProfileCallback: (_) {
            throw _dioError(
              type: DioExceptionType.badResponse,
              statusCode: 422,
              data: {'message': 'Email không hợp lệ.'},
            );
          },
        ),
      );

      expect(
        () => repository.updateProfile(request: _request),
        throwsA(isA<ValidationException>()),
      );
    });

    test('uploadAvatar forwards file path and returns upload result', () async {
      String? capturedPath;
      final repository = buildRepository(
        _FakeStudentProfileRemoteDataSource(
          uploadAvatarCallback: (filePath) async {
            capturedPath = filePath;
            return const AvatarUploadResult(
              success: true,
              imageUrl: 'https://example.test/avatar.png',
            );
          },
        ),
      );

      final result = await repository.uploadAvatar(
        filePath: 'C:\\images\\avatar.png',
      );

      expect(capturedPath, 'C:\\images\\avatar.png');
      expect(result.success, isTrue);
    });

    test('uploadAvatar maps malformed response to UnexpectedException', () {
      final repository = buildRepository(
        _FakeStudentProfileRemoteDataSource(
          uploadAvatarCallback: (_) {
            throw const FormatException('invalid upload result');
          },
        ),
      );

      expect(
        () => repository.uploadAvatar(filePath: 'avatar.png'),
        throwsA(
          isA<UnexpectedException>().having(
            (error) => error.message,
            'message',
            'Kết quả tải ảnh đại diện không hợp lệ.',
          ),
        ),
      );
    });
  });
}

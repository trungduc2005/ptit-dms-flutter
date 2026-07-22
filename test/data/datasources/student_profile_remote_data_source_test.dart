import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptit_dms_flutter/core/network/bearer_auth_interceptor.dart';
import 'package:ptit_dms_flutter/data/datasources/student_profile_remote_data_source.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';

void main() {
  Map<String, dynamic> profileJson() {
    return {
      '_id': 'profile-01',
      'studentId': 'B21DCCN001',
      'cohort': 'D21',
      'major': ['Công nghệ thông tin'],
      'classId': {'_id': 'class-01', 'name': 'D21CQCN01-B'},
      'userId': {
        '_id': 'user-01',
        'fullName': 'Nguyễn Văn A',
        'username': 'B21DCCN001',
        'email': 'student@ptit.edu.vn',
        'phone': '0912345678',
        'gender': 'male',
        'dateOfBirth': '2003-07-22T00:00:00.000Z',
      },
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

  group('StudentProfileRemoteDataSource', () {
    test(
      'gets and parses the current profile with bearer auth enabled',
      () async {
        RequestOptions? captured;
        final dataSource = StudentProfileRemoteDataSource(
          createStubDio(
            (_) => profileJson(),
            capture: (options) => captured = options,
          ),
        );

        final profile = await dataSource.getProfile();

        expect(captured!.method, 'GET');
        expect(captured!.path, '/info');
        expect(captured!.extra[requiresBearerAuthKey], isTrue);
        expect(profile.studentId, 'B21DCCN001');
        expect(profile.classInfo?.name, 'D21CQCN01-B');
        expect(profile.user?.email, 'student@ptit.edu.vn');
        expect(profile.user?.dateOfBirth, DateTime.utc(2003, 7, 22));
      },
    );

    test('updates profile with only supported request keys', () async {
      RequestOptions? captured;
      const request = StudentProfileUpdateRequest(
        email: 'new@ptit.edu.vn',
        phone: '0987654321',
        gender: 'female',
        dateOfBirth: null,
        address: 'Hà Nội',
      );
      final dataSource = StudentProfileRemoteDataSource(
        createStubDio(
          (_) => {'message': 'Thành công', 'info': profileJson()},
          capture: (options) => captured = options,
        ),
      );

      final profile = await dataSource.updateProfile(request: request);

      expect(captured!.method, 'PUT');
      expect(captured!.path, '/info/update');
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(captured!.data, {
        'email': 'new@ptit.edu.vn',
        'phone': '0987654321',
        'gender': 'female',
        'address': 'Hà Nội',
      });
      expect(profile.id, 'profile-01');
    });

    test('parses a direct profile object from update response', () async {
      final dataSource = StudentProfileRemoteDataSource(
        createStubDio((_) => profileJson()),
      );

      final profile = await dataSource.updateProfile(
        request: const StudentProfileUpdateRequest(),
      );

      expect(profile.studentId, 'B21DCCN001');
    });

    test('uploads avatar as multipart using the avatar field name', () async {
      RequestOptions? captured;
      final dataSource = StudentProfileRemoteDataSource(
        createStubDio(
          (_) => {
            'success': true,
            'imageUrl': 'https://example.test/avatar.png',
          },
          capture: (options) => captured = options,
        ),
      );

      final result = await dataSource.uploadAvatar(
        filePath: 'assets/icons/project.svg',
      );

      expect(captured!.method, 'POST');
      expect(captured!.path, '/info/upload-avatar');
      expect(captured!.extra[requiresBearerAuthKey], isTrue);
      expect(captured!.data, isA<FormData>());
      final formData = captured!.data as FormData;
      expect(formData.files, hasLength(1));
      expect(formData.files.single.key, 'avatar');
      expect(formData.files.single.value.filename, 'project.svg');
      expect(result.success, isTrue);
      expect(result.imageUrl, 'https://example.test/avatar.png');
    });

    test('normalizes a non-object GET response to an empty profile', () async {
      final dataSource = StudentProfileRemoteDataSource(
        createStubDio((_) => <Object?>[]),
      );

      final profile = await dataSource.getProfile();

      expect(profile.id, isEmpty);
      expect(profile.studentId, isEmpty);
      expect(profile.major, isEmpty);
      expect(profile.user, isNull);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/avatar_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/profile_submit_bloc.dart';

class _MockStudentProfileRepository extends Mock
    implements StudentProfileRepository {}

class _FakeStudentProfileUpdateRequest extends Fake
    implements StudentProfileUpdateRequest {}

const _request = StudentProfileUpdateRequest(
  email: 'student@ptit.edu.vn',
  phone: '0912345678',
  gender: 'male',
  address: 'Hà Nội',
);

const _updatedProfile = StudentProfile(
  id: 'profile-01',
  studentId: 'B21DCCN001',
  cohort: 'D21',
  major: ['Công nghệ thông tin'],
  user: StudentProfileUser(
    id: 'user-01',
    fullName: 'Nguyễn Văn A',
    username: 'B21DCCN001',
    email: 'student@ptit.edu.vn',
    phone: '0912345678',
  ),
);

void main() {
  late _MockStudentProfileRepository repository;

  setUpAll(() {
    registerFallbackValue(_FakeStudentProfileUpdateRequest());
  });

  setUp(() {
    repository = _MockStudentProfileRepository();
  });

  ProfileSubmitBloc buildBloc() => ProfileSubmitBloc(repository);

  group('ProfileSubmitBloc', () {
    test('initial state is ProfileSubmitState()', () {
      expect(buildBloc().state, const ProfileSubmitState());
    });

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'valid update emits loading then success',
      setUp: () {
        when(
          () => repository.updateProfile(request: _request),
        ).thenAnswer((_) async => _updatedProfile);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProfileUpdateSubmitted(request: _request)),
      expect: () => const [
        ProfileSubmitState(submitStatus: ProfileSubmitStatus.loading),
        ProfileSubmitState(
          submitStatus: ProfileSubmitStatus.success,
          updatedProfile: _updatedProfile,
          message: 'Cập nhật thông tin thành công.',
        ),
      ],
      verify: (_) {
        verify(() => repository.updateProfile(request: _request)).called(1);
      },
    );

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'invalid email emits validation failure without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProfileUpdateSubmitted(
          request: StudentProfileUpdateRequest(email: 'invalid-email'),
        ),
      ),
      expect: () => const [
        ProfileSubmitState(
          submitStatus: ProfileSubmitStatus.failure,
          message: 'Email không hợp lệ.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.updateProfile(request: any(named: 'request')),
        );
      },
    );

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'invalid phone emits validation failure without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProfileUpdateSubmitted(
          request: StudentProfileUpdateRequest(phone: '123'),
        ),
      ),
      expect: () => const [
        ProfileSubmitState(
          submitStatus: ProfileSubmitStatus.failure,
          message: 'Số điện thoại không hợp lệ.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.updateProfile(request: any(named: 'request')),
        );
      },
    );

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'update preserves mapped AppException message',
      setUp: () {
        when(
          () => repository.updateProfile(request: _request),
        ).thenThrow(const ValidationException('Email đã được sử dụng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProfileUpdateSubmitted(request: _request)),
      expect: () => const [
        ProfileSubmitState(submitStatus: ProfileSubmitStatus.loading),
        ProfileSubmitState(
          submitStatus: ProfileSubmitStatus.failure,
          message: 'Email đã được sử dụng.',
        ),
      ],
    );

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'avatar upload emits loading then success',
      setUp: () {
        when(
          () => repository.uploadAvatar(filePath: 'C:\\images\\avatar.png'),
        ).thenAnswer(
          (_) async => const AvatarUploadResult(
            success: true,
            imageUrl: 'https://example.test/avatar.png',
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProfileAvatarUploadRequested(filePath: 'C:\\images\\avatar.png'),
      ),
      expect: () => const [
        ProfileSubmitState(uploadStatus: ProfileAvatarUploadStatus.loading),
        ProfileSubmitState(
          uploadStatus: ProfileAvatarUploadStatus.success,
          uploadedAvatar: AvatarUploadResult(
            success: true,
            imageUrl: 'https://example.test/avatar.png',
          ),
          message: 'Upload avatar thành công.',
        ),
      ],
    );

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'avatar upload emits failure when repository result is unsuccessful',
      setUp: () {
        when(
          () => repository.uploadAvatar(filePath: 'C:\\images\\avatar.png'),
        ).thenAnswer((_) async => const AvatarUploadResult(success: false));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProfileAvatarUploadRequested(filePath: 'C:\\images\\avatar.png'),
      ),
      expect: () => const [
        ProfileSubmitState(uploadStatus: ProfileAvatarUploadStatus.loading),
        ProfileSubmitState(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          message: 'Upload avatar thất bại.',
        ),
      ],
    );

    blocTest<ProfileSubmitBloc, ProfileSubmitState>(
      'avatar upload preserves mapped AppException message',
      setUp: () {
        when(
          () => repository.uploadAvatar(filePath: 'C:\\images\\avatar.png'),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ProfileAvatarUploadRequested(filePath: 'C:\\images\\avatar.png'),
      ),
      expect: () => const [
        ProfileSubmitState(uploadStatus: ProfileAvatarUploadStatus.loading),
        ProfileSubmitState(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          message: 'Không có kết nối mạng.',
        ),
      ],
    );
  });
}

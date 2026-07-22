import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';
import 'package:ptit_dms_flutter/features/profile/bloc/profile_context_bloc.dart';

class _MockStudentProfileRepository extends Mock
    implements StudentProfileRepository {}

const _profile = StudentProfile(
  id: 'profile-01',
  studentId: 'B21DCCN001',
  cohort: 'D21',
  major: ['Công nghệ thông tin'],
  user: StudentProfileUser(
    id: 'user-01',
    fullName: 'Nguyễn Văn A',
    username: 'B21DCCN001',
    email: 'student@ptit.edu.vn',
  ),
);

void main() {
  late _MockStudentProfileRepository repository;

  setUp(() {
    repository = _MockStudentProfileRepository();
  });

  ProfileContextBloc buildBloc() => ProfileContextBloc(repository);

  group('ProfileContextBloc', () {
    test('initial state is ProfileContextState()', () {
      expect(buildBloc().state, const ProfileContextState());
    });

    blocTest<ProfileContextBloc, ProfileContextState>(
      'started emits loading then success',
      setUp: () {
        when(() => repository.getProfile()).thenAnswer((_) async => _profile);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProfileContextStarted()),
      expect: () => const [
        ProfileContextState(status: ProfileContextStatus.loading),
        ProfileContextState(
          status: ProfileContextStatus.success,
          profile: _profile,
        ),
      ],
      verify: (_) {
        verify(() => repository.getProfile()).called(1);
      },
    );

    blocTest<ProfileContextBloc, ProfileContextState>(
      'started preserves mapped AppException message on failure',
      setUp: () {
        when(
          () => repository.getProfile(),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProfileContextStarted()),
      expect: () => const [
        ProfileContextState(status: ProfileContextStatus.loading),
        ProfileContextState(
          status: ProfileContextStatus.failure,
          errorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ProfileContextBloc, ProfileContextState>(
      'refresh emits loading then success and replaces the current profile',
      setUp: () {
        when(() => repository.getProfile()).thenAnswer((_) async => _profile);
      },
      build: buildBloc,
      seed: () => const ProfileContextState(
        status: ProfileContextStatus.success,
        profile: StudentProfile(
          id: 'old-profile',
          studentId: 'OLD',
          cohort: 'D20',
          major: [],
        ),
      ),
      act: (bloc) => bloc.add(const ProfileContextRefreshed()),
      expect: () => const [
        ProfileContextState(
          status: ProfileContextStatus.loading,
          profile: StudentProfile(
            id: 'old-profile',
            studentId: 'OLD',
            cohort: 'D20',
            major: [],
          ),
        ),
        ProfileContextState(
          status: ProfileContextStatus.success,
          profile: _profile,
        ),
      ],
    );

    blocTest<ProfileContextBloc, ProfileContextState>(
      'refresh keeps current profile and emits mapped failure message',
      setUp: () {
        when(
          () => repository.getProfile(),
        ).thenThrow(const ServerException('Máy chủ đang bận.'));
      },
      build: buildBloc,
      seed: () => const ProfileContextState(
        status: ProfileContextStatus.success,
        profile: _profile,
      ),
      act: (bloc) => bloc.add(const ProfileContextRefreshed()),
      expect: () => const [
        ProfileContextState(
          status: ProfileContextStatus.loading,
          profile: _profile,
        ),
        ProfileContextState(
          status: ProfileContextStatus.failure,
          profile: _profile,
          errorMessage: 'Máy chủ đang bận.',
        ),
      ],
    );
  });
}

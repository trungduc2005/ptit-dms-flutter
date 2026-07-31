import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_registration/bloc/research_registration_bloc.dart';

class _MockResearchRepository extends Mock implements ResearchRepository {}

class _MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  const yearId = 'year-1';
  const type = 'student';

  const request = ResearchRegistrationRequest(
    yearId: yearId,
    type: type,
    researchTopic: 'Ứng dụng AI trong giáo dục',
    keyword: 'AI, giáo dục',
    outcome: 'Mô hình thử nghiệm',
    description: 'Nghiên cứu ứng dụng AI.',
    researchNecessity: 'Cần nâng cao chất lượng học tập.',
    nationalOverview: 'Tổng quan trong nước.',
    internationalOverview: 'Tổng quan quốc tế.',
    members: [ResearchRegistrationMemberRequest(memberId: 'student-2')],
  );

  const research = Research(
    id: 'object-1',
    userId: 'user-1',
    researchId: 'RESEARCH-001',
    type: type,
    researchTopic: 'Ứng dụng AI trong giáo dục',
    keyword: 'AI, giáo dục',
    outcome: 'Mô hình thử nghiệm',
    description: 'Nghiên cứu ứng dụng AI.',
    researchNecessity: 'Cần nâng cao chất lượng học tập.',
    nationalOverview: 'Tổng quan trong nước.',
    internationalOverview: 'Tổng quan quốc tế.',
    yearId: yearId,
    approvalStatus: 'pending',
    members: [],
    comments: [],
  );

  final registrationTimeline = Timeline(
    id: 'timeline-1',
    name: 'Đăng ký nghiên cứu khoa học',
    type: 'researchRegistration',
    startTime: DateTime(2026, 8, 1, 8),
    endTime: DateTime(2026, 8, 31, 17),
  );

  const updatedResearch = Research(
    id: 'object-1',
    userId: 'user-1',
    researchId: 'RESEARCH-001',
    type: type,
    researchTopic: 'Ứng dụng AI trong giáo dục - cập nhật',
    keyword: 'AI, giáo dục',
    outcome: 'Mô hình hoàn chỉnh',
    description: 'Nghiên cứu ứng dụng AI.',
    researchNecessity: 'Cần nâng cao chất lượng học tập.',
    nationalOverview: 'Tổng quan trong nước.',
    internationalOverview: 'Tổng quan quốc tế.',
    yearId: yearId,
    approvalStatus: 'pending',
    members: [],
    comments: [],
  );

  late _MockResearchRepository repository;
  late _MockTimelineRepository timelineRepository;

  setUpAll(() {
    registerFallbackValue(request);
  });

  setUp(() {
    repository = _MockResearchRepository();
    timelineRepository = _MockTimelineRepository();
    when(
      () => timelineRepository.getResearchTimelines(
        academicYearId: any(named: 'academicYearId'),
      ),
    ).thenAnswer((_) async => const []);
  });

  ResearchRegistrationBloc buildBloc() => ResearchRegistrationBloc(
    repository: repository,
    timelineRepository: timelineRepository,
  );

  group('ResearchRegistrationBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ResearchRegistrationState());
    });

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'loads user researches and registration timeline then emits success',
      setUp: () {
        when(
          () => repository.getUserResearches(yearId: yearId, type: type),
        ).thenAnswer((_) async => const [research]);
        when(
          () => timelineRepository.getResearchTimelines(academicYearId: yearId),
        ).thenAnswer(
          (_) async => [
            const Timeline(
              id: 'other-timeline',
              name: 'Timeline khác',
              type: 'projectRegistration',
            ),
            registrationTimeline,
          ],
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchRegistrationStarted(
          yearId: '  $yearId  ',
          type: '  $type  ',
        ),
      ),
      expect: () => [
        const ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.loading,
          yearId: yearId,
          type: type,
        ),
        ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.success,
          yearId: yearId,
          type: type,
          researches: const [research],
          registrationTimeline: registrationTimeline,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getUserResearches(yearId: yearId, type: type),
        ).called(1);
        verify(
          () => timelineRepository.getResearchTimelines(academicYearId: yearId),
        ).called(1);
        verifyNever(
          () => timelineRepository.getProjectTimelines(
            academicYearId: any(named: 'academicYearId'),
          ),
        );
      },
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'uses the first scoped timeline when the API returns a legacy type',
      setUp: () {
        when(
          () => repository.getUserResearches(yearId: yearId, type: type),
        ).thenAnswer((_) async => const [research]);
        when(
          () => timelineRepository.getResearchTimelines(academicYearId: yearId),
        ).thenAnswer(
          (_) async => [
            Timeline(
              id: 'legacy-research-timeline',
              name: 'Đăng ký nghiên cứu khoa học',
              type: 'registration',
              startTime: DateTime(2026, 7, 3, 8),
              endTime: DateTime(2026, 7, 31, 14, 59),
            ),
          ],
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchRegistrationStarted(yearId: yearId, type: type),
      ),
      expect: () => [
        const ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.loading,
          yearId: yearId,
          type: type,
        ),
        ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.success,
          yearId: yearId,
          type: type,
          researches: const [research],
          registrationTimeline: Timeline(
            id: 'legacy-research-timeline',
            name: 'Đăng ký nghiên cứu khoa học',
            type: 'registration',
            startTime: DateTime(2026, 7, 3, 8),
            endTime: DateTime(2026, 7, 31, 14, 59),
          ),
        ),
      ],
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'does not call repository when load parameters are invalid',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchRegistrationStarted(yearId: ' ', type: type)),
      expect: () => const [
        ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.failure,
          type: type,
          loadErrorMessage: 'Thiếu năm học.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.getUserResearches(
          yearId: any(named: 'yearId'),
          type: any(named: 'type'),
        ),
      ),
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getUserResearches(yearId: yearId, type: type),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchRegistrationStarted(yearId: yearId, type: type),
      ),
      expect: () => const [
        ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.loading,
          yearId: yearId,
          type: type,
        ),
        ResearchRegistrationState(
          loadStatus: ResearchRegistrationLoadStatus.failure,
          yearId: yearId,
          type: type,
          loadErrorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'creates research and inserts it into the current list',
      setUp: () {
        when(
          () => repository.createResearch(request: request),
        ).thenAnswer((_) async => research);
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchRegistrationCreated(request: request)),
      expect: () => const [
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.loading,
          action: ResearchRegistrationAction.create,
        ),
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.success,
          action: ResearchRegistrationAction.create,
          researches: [research],
          savedResearch: research,
          actionMessage: 'Đăng ký nghiên cứu khoa học thành công.',
        ),
      ],
      verify: (_) {
        verify(() => repository.createResearch(request: request)).called(1);
      },
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'updates research and replaces it in the current list',
      setUp: () {
        when(
          () => repository.updateResearch(
            researchId: research.researchId,
            request: request,
          ),
        ).thenAnswer((_) async => updatedResearch);
      },
      build: buildBloc,
      seed: () => const ResearchRegistrationState(researches: [research]),
      act: (bloc) => bloc.add(
        const ResearchRegistrationUpdated(
          researchId: '  RESEARCH-001  ',
          request: request,
        ),
      ),
      expect: () => const [
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.loading,
          action: ResearchRegistrationAction.update,
          researches: [research],
        ),
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.success,
          action: ResearchRegistrationAction.update,
          researches: [updatedResearch],
          savedResearch: updatedResearch,
          actionMessage: 'Cập nhật nghiên cứu khoa học thành công.',
        ),
      ],
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'rejects an invalid request without calling repository',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchRegistrationCreated(
          request: ResearchRegistrationRequest(
            yearId: yearId,
            type: type,
            researchTopic: ' ',
            keyword: 'keyword',
            outcome: 'outcome',
            description: 'description',
            researchNecessity: 'necessity',
            nationalOverview: 'national',
            internationalOverview: 'international',
          ),
        ),
      ),
      expect: () => const [
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: ResearchRegistrationAction.create,
          actionMessage: 'Bạn phải nhập tên đề tài nghiên cứu.',
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.createResearch(request: any(named: 'request')),
      ),
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'preserves AppException message when create fails',
      setUp: () {
        when(
          () => repository.createResearch(request: request),
        ).thenThrow(const ValidationException('Dữ liệu không hợp lệ.'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchRegistrationCreated(request: request)),
      expect: () => const [
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.loading,
          action: ResearchRegistrationAction.create,
        ),
        ResearchRegistrationState(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: ResearchRegistrationAction.create,
          actionMessage: 'Dữ liệu không hợp lệ.',
        ),
      ],
    );

    blocTest<ResearchRegistrationBloc, ResearchRegistrationState>(
      'clears the action state after UI handles its message',
      build: buildBloc,
      seed: () => const ResearchRegistrationState(
        actionStatus: ResearchRegistrationActionStatus.success,
        action: ResearchRegistrationAction.create,
        researches: [research],
        savedResearch: research,
        actionMessage: 'Đăng ký nghiên cứu khoa học thành công.',
      ),
      act: (bloc) => bloc.add(const ResearchRegistrationActionStateCleared()),
      expect: () => const [
        ResearchRegistrationState(researches: [research]),
      ],
    );
  });
}

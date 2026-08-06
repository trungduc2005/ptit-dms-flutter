import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_seminar_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_seminar_committee_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_seminar_committee/bloc/research_seminar_committee_bloc.dart';

class _MockResearchSeminarCommitteeRepository extends Mock
    implements ResearchSeminarCommitteeRepository {}

const _yearId = 'year-1';

const _researches = [
  ResearchSeminarOption(
    researchId: 'research-1',
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
  ),
  ResearchSeminarOption(
    researchId: 'research-2',
    researchTopic: 'Phân tích dữ liệu',
  ),
];

final _committee = ResearchSeminarCommittee(
  committeeId: 'committee-1',
  name: 'Hội đồng hội thảo số 1',
  time: '08:30',
  date: DateTime(2026, 8, 10),
  location: 'Phòng 101',
  members: const [
    ResearchSeminarCommitteeMember(
      memberId: 'lecturer-1',
      memberName: 'Nguyễn Văn A',
      department: 'Công nghệ thông tin',
      role: 'Chủ tịch',
    ),
  ],
  research: const ResearchSeminarCommitteeResearch(
    researchId: 'research-1',
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
    presentationOrder: 1,
    reviewerName: 'Trần Văn B',
  ),
);

void main() {
  late _MockResearchSeminarCommitteeRepository repository;

  setUp(() {
    repository = _MockResearchSeminarCommitteeRepository();
  });

  ResearchSeminarCommitteeBloc buildBloc() =>
      ResearchSeminarCommitteeBloc(repository: repository);

  group('ResearchSeminarCommitteeBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ResearchSeminarCommitteeState());
    });

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'loads normalized year and selects the committee research',
      setUp: () {
        when(() => repository.getMyCommittee(yearId: _yearId)).thenAnswer(
          (_) async => ResearchSeminarCommitteeResult(
            researches: _researches,
            committee: _committee,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchSeminarCommitteeStarted(
          yearId: '  $_yearId  ',
          researchId: '   ',
        ),
      ),
      expect: () => [
        const ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.success,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-1',
          committee: _committee,
        ),
      ],
      verify: (_) {
        verify(() => repository.getMyCommittee(yearId: _yearId)).called(1);
      },
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'loads the automatically selected research when the initial response '
      'does not include a committee',
      setUp: () {
        when(() => repository.getMyCommittee(yearId: _yearId)).thenAnswer(
          (_) async => const ResearchSeminarCommitteeResult(
            researches: _researches,
            committee: null,
          ),
        );
        when(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-1',
          ),
        ).thenAnswer(
          (_) async => ResearchSeminarCommitteeResult(
            researches: _researches,
            committee: _committee,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchSeminarCommitteeStarted(yearId: _yearId)),
      expect: () => [
        const ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.success,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-1',
          committee: _committee,
        ),
      ],
      verify: (_) {
        verify(() => repository.getMyCommittee(yearId: _yearId)).called(1);
        verify(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-1',
          ),
        ).called(1);
      },
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'rejects a blank year without calling repository',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchSeminarCommitteeStarted(yearId: '   ')),
      expect: () => const [
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.failure,
          errorMessage: 'Thiếu thông tin năm học của hội đồng hội thảo.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => repository.getMyCommittee(
            yearId: any(named: 'yearId'),
            researchId: any(named: 'researchId'),
          ),
        );
      },
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getMyCommittee(yearId: _yearId),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchSeminarCommitteeStarted(yearId: _yearId)),
      expect: () => const [
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.failure,
          yearId: _yearId,
          errorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'maps an unexpected error to the fallback message',
      setUp: () {
        when(
          () => repository.getMyCommittee(yearId: _yearId),
        ).thenThrow(StateError('unexpected'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchSeminarCommitteeStarted(yearId: _yearId)),
      expect: () => const [
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.failure,
          yearId: _yearId,
          errorMessage: 'Không thể tải thông tin hội đồng hội thảo.',
        ),
      ],
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'keeps current data while refreshing',
      setUp: () {
        when(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-1',
          ),
        ).thenAnswer(
          (_) async => ResearchSeminarCommitteeResult(
            researches: _researches,
            committee: _committee,
          ),
        );
      },
      build: buildBloc,
      seed: () => ResearchSeminarCommitteeState(
        status: ResearchSeminarCommitteeStatus.success,
        yearId: _yearId,
        researches: _researches,
        selectedResearchId: 'research-1',
        committee: _committee,
      ),
      act: (bloc) => bloc.add(const ResearchSeminarCommitteeRefreshed()),
      expect: () => [
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.loading,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-1',
          committee: _committee,
        ),
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.success,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-1',
          committee: _committee,
        ),
      ],
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'does nothing when refreshing before a year is loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(const ResearchSeminarCommitteeRefreshed()),
      expect: () => <ResearchSeminarCommitteeState>[],
      verify: (_) {
        verifyNever(
          () => repository.getMyCommittee(
            yearId: any(named: 'yearId'),
            researchId: any(named: 'researchId'),
          ),
        );
      },
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'loads the committee when an available research is selected',
      setUp: () {
        when(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-2',
          ),
        ).thenAnswer(
          (_) async => const ResearchSeminarCommitteeResult(
            researches: _researches,
            committee: null,
          ),
        );
      },
      build: buildBloc,
      seed: () => ResearchSeminarCommitteeState(
        status: ResearchSeminarCommitteeStatus.success,
        yearId: _yearId,
        researches: _researches,
        selectedResearchId: 'research-1',
        committee: _committee,
      ),
      act: (bloc) => bloc.add(
        const ResearchSeminarCommitteeResearchSelected('  research-2  '),
      ),
      expect: () => [
        ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.loading,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-2',
          committee: _committee,
        ),
        const ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.success,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-2',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-2',
          ),
        ).called(1);
      },
    );

    blocTest<ResearchSeminarCommitteeBloc, ResearchSeminarCommitteeState>(
      'ignores a research that is not in the available list',
      build: buildBloc,
      seed: () => const ResearchSeminarCommitteeState(
        status: ResearchSeminarCommitteeStatus.success,
        yearId: _yearId,
        researches: _researches,
        selectedResearchId: 'research-1',
      ),
      act: (bloc) =>
          bloc.add(const ResearchSeminarCommitteeResearchSelected('unknown')),
      expect: () => <ResearchSeminarCommitteeState>[],
      verify: (_) {
        verifyNever(
          () => repository.getMyCommittee(
            yearId: any(named: 'yearId'),
            researchId: any(named: 'researchId'),
          ),
        );
      },
    );

    group('ResearchSeminarCommitteeState', () {
      test('derived properties reflect loaded data', () {
        const emptyState = ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.success,
        );
        final loadedState = ResearchSeminarCommitteeState(
          status: ResearchSeminarCommitteeStatus.success,
          researches: _researches,
          selectedResearchId: 'research-2',
          committee: _committee,
        );

        expect(emptyState.isEmpty, isTrue);
        expect(emptyState.hasCommittee, isFalse);
        expect(loadedState.isEmpty, isFalse);
        expect(loadedState.hasCommittee, isTrue);
        expect(loadedState.selectedResearch, _researches[1]);
      });

      test('copyWith can explicitly clear nullable values', () {
        final state = ResearchSeminarCommitteeState(
          selectedResearchId: 'research-1',
          committee: _committee,
          errorMessage: 'old error',
        );

        // ignore: avoid_redundant_argument_values
        final updated = state.copyWith(
          selectedResearchId: null,
          committee: null,
          errorMessage: null,
        );

        expect(updated.selectedResearchId, isNull);
        expect(updated.committee, isNull);
        expect(updated.errorMessage, isNull);
      });
    });
  });
}

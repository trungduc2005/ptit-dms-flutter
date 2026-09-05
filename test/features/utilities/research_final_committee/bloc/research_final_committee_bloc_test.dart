import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research_final_committee.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_final_committee_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/research_final_committee/bloc/research_final_committee_bloc.dart';

class _MockResearchFinalCommitteeRepository extends Mock
    implements ResearchFinalCommitteeRepository {}

const _yearId = 'year-1';

const _researches = [
  ResearchFinalOption(
    researchId: 'research-1',
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
  ),
  ResearchFinalOption(
    researchId: 'research-2',
    researchTopic: 'Phân tích dữ liệu',
  ),
];

final _committee = ResearchFinalCommittee(
  committeeId: 'committee-1',
  name: 'Hội đồng nghiệm thu số 1',
  time: '08:30',
  date: DateTime(2026, 8, 10),
  location: 'Phòng 101',
  members: const [
    ResearchFinalCommitteeMember(
      memberId: 'lecturer-1',
      memberName: 'Nguyễn Văn A',
      department: 'Công nghệ thông tin',
      role: 'Chủ tịch',
    ),
  ],
  research: const ResearchFinalCommitteeResearch(
    researchId: 'research-1',
    researchTopic: 'Ứng dụng trí tuệ nhân tạo',
    presentationOrder: 1,
    reviewerName: 'Trần Văn B',
  ),
);

void main() {
  late _MockResearchFinalCommitteeRepository repository;

  setUp(() {
    repository = _MockResearchFinalCommitteeRepository();
  });

  ResearchFinalCommitteeBloc buildBloc() =>
      ResearchFinalCommitteeBloc(repository: repository);

  group('ResearchFinalCommitteeBloc', () {
    test('has the expected initial state', () {
      expect(buildBloc().state, const ResearchFinalCommitteeState());
    });

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'loads normalized year and selects the committee research',
      setUp: () {
        when(() => repository.getMyCommittee(yearId: _yearId)).thenAnswer(
          (_) async => ResearchFinalCommitteeResult(
            researches: _researches,
            committee: _committee,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ResearchFinalCommitteeStarted(
          yearId: '  $_yearId  ',
          researchId: '   ',
        ),
      ),
      expect: () => [
        const ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.success,
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

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'loads the automatically selected research when the initial response '
      'does not include a committee',
      setUp: () {
        when(() => repository.getMyCommittee(yearId: _yearId)).thenAnswer(
          (_) async => const ResearchFinalCommitteeResult(
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
          (_) async => ResearchFinalCommitteeResult(
            researches: _researches,
            committee: _committee,
          ),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchFinalCommitteeStarted(yearId: _yearId)),
      expect: () => [
        const ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.success,
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

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'rejects a blank year without calling repository',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchFinalCommitteeStarted(yearId: '   ')),
      expect: () => const [
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.failure,
          errorMessage: 'Thiếu thông tin năm học của hội đồng nghiệm thu.',
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

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'preserves AppException message when loading fails',
      setUp: () {
        when(
          () => repository.getMyCommittee(yearId: _yearId),
        ).thenThrow(const NetworkException('Không có kết nối mạng.'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchFinalCommitteeStarted(yearId: _yearId)),
      expect: () => const [
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.failure,
          yearId: _yearId,
          errorMessage: 'Không có kết nối mạng.',
        ),
      ],
    );

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'maps an unexpected error to the fallback message',
      setUp: () {
        when(
          () => repository.getMyCommittee(yearId: _yearId),
        ).thenThrow(StateError('unexpected'));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ResearchFinalCommitteeStarted(yearId: _yearId)),
      expect: () => const [
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.loading,
          yearId: _yearId,
        ),
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.failure,
          yearId: _yearId,
          errorMessage: 'Không thể tải thông tin hội đồng nghiệm thu.',
        ),
      ],
    );

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'keeps current data while refreshing',
      setUp: () {
        when(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-1',
          ),
        ).thenAnswer(
          (_) async => ResearchFinalCommitteeResult(
            researches: _researches,
            committee: _committee,
          ),
        );
      },
      build: buildBloc,
      seed: () => ResearchFinalCommitteeState(
        status: ResearchFinalCommitteeStatus.success,
        yearId: _yearId,
        researches: _researches,
        selectedResearchId: 'research-1',
        committee: _committee,
      ),
      act: (bloc) => bloc.add(const ResearchFinalCommitteeRefreshed()),
      expect: () => [
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.loading,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-1',
          committee: _committee,
        ),
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.success,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-1',
          committee: _committee,
        ),
      ],
    );

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'does nothing when refreshing before a year is loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(const ResearchFinalCommitteeRefreshed()),
      expect: () => <ResearchFinalCommitteeState>[],
      verify: (_) {
        verifyNever(
          () => repository.getMyCommittee(
            yearId: any(named: 'yearId'),
            researchId: any(named: 'researchId'),
          ),
        );
      },
    );

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'loads the committee when an available research is selected',
      setUp: () {
        when(
          () => repository.getMyCommittee(
            yearId: _yearId,
            researchId: 'research-2',
          ),
        ).thenAnswer(
          (_) async => const ResearchFinalCommitteeResult(
            researches: _researches,
            committee: null,
          ),
        );
      },
      build: buildBloc,
      seed: () => ResearchFinalCommitteeState(
        status: ResearchFinalCommitteeStatus.success,
        yearId: _yearId,
        researches: _researches,
        selectedResearchId: 'research-1',
        committee: _committee,
      ),
      act: (bloc) => bloc.add(
        const ResearchFinalCommitteeResearchSelected('  research-2  '),
      ),
      expect: () => [
        ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.loading,
          yearId: _yearId,
          researches: _researches,
          selectedResearchId: 'research-2',
          committee: _committee,
        ),
        const ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.success,
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

    blocTest<ResearchFinalCommitteeBloc, ResearchFinalCommitteeState>(
      'ignores a research that is not in the available list',
      build: buildBloc,
      seed: () => const ResearchFinalCommitteeState(
        status: ResearchFinalCommitteeStatus.success,
        yearId: _yearId,
        researches: _researches,
        selectedResearchId: 'research-1',
      ),
      act: (bloc) =>
          bloc.add(const ResearchFinalCommitteeResearchSelected('unknown')),
      expect: () => <ResearchFinalCommitteeState>[],
      verify: (_) {
        verifyNever(
          () => repository.getMyCommittee(
            yearId: any(named: 'yearId'),
            researchId: any(named: 'researchId'),
          ),
        );
      },
    );

    group('ResearchFinalCommitteeState', () {
      test('derived properties reflect loaded data', () {
        const emptyState = ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.success,
        );
        final loadedState = ResearchFinalCommitteeState(
          status: ResearchFinalCommitteeStatus.success,
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
        final state = ResearchFinalCommitteeState(
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

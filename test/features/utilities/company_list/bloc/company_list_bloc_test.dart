import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/features/utilities/company_list/bloc/company_list_bloc.dart';

class _MockCompanyRepository extends Mock implements CompanyRepository {}

class _MockAcademicYearRepository extends Mock
    implements AcademicYearRepository {}

const _tYear = AcademicYearOption(
  id: 'y1',
  code: '2024-2025',
  name: 'Năm học 2024-2025',
);

const _tOtherYear = AcademicYearOption(
  id: 'y2',
  code: '2023-2024',
  name: 'Năm học 2023-2024',
);

const _tCompany = Company(
  id: 'c1',
  companyId: 'C001',
  companyName: 'PTIT Corp',
);

void main() {
  late _MockCompanyRepository companyRepo;
  late _MockAcademicYearRepository academicYearRepo;

  setUp(() {
    companyRepo = _MockCompanyRepository();
    academicYearRepo = _MockAcademicYearRepository();
  });

  CompanyListBloc buildBloc() => CompanyListBloc(companyRepo, academicYearRepo);

  // ── Stub helpers ──────────────────────────────────────────────────────

  void stubYears(List<AcademicYearOption> years) {
    when(
      () => academicYearRepo.getInternAcademicYears(),
    ).thenAnswer((_) async => years);
  }

  void stubCompanies(String code, List<Company> companies) {
    when(
      () => companyRepo.getCompanies(
        academicYearCode: code,
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => companies);
  }

  void stubYearsThrows(AppException e) {
    when(() => academicYearRepo.getInternAcademicYears()).thenThrow(e);
  }

  void stubCompaniesThrows(String code, AppException e) {
    when(
      () => companyRepo.getCompanies(
        academicYearCode: code,
        search: any(named: 'search'),
      ),
    ).thenThrow(e);
  }

  const loadingState = CompanyListState(status: CompanyListStatus.loading);

  // ── Tests ─────────────────────────────────────────────────────────────

  group('CompanyListBloc –', () {
    test('initial state is CompanyListState()', () {
      expect(buildBloc().state, const CompanyListState());
    });

    // ── CompanyListStarted ──────────────────────────────────────────────
    group('on CompanyListStarted –', () {
      blocTest<CompanyListBloc, CompanyListState>(
        'emits [loading, success] with companies on happy path',
        setUp: () {
          stubYears([_tYear]);
          stubCompanies(_tYear.code, [_tCompany]);
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListStarted()),
        expect: () => [
          loadingState,
          const CompanyListState(
            status: CompanyListStatus.success,
            companies: [_tCompany],
            academicYears: [_tYear],
            selectedAcademicYear: _tYear,
          ),
        ],
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'emits [loading, success] with empty list when no academic years',
        setUp: () {
          stubYears([]);
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListStarted()),
        expect: () => [
          loadingState,
          const CompanyListState(
            status: CompanyListStatus.success,
            companies: [],
          ),
        ],
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'emits [loading, failure] when academicYearRepository throws NetworkException',
        setUp: () {
          stubYearsThrows(NetworkException('No internet connection'));
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListStarted()),
        expect: () => [
          loadingState,
          isA<CompanyListState>()
              .having((s) => s.status, 'status', CompanyListStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'emits [loading, failure] when companyRepository throws UnauthorizedException',
        setUp: () {
          stubYears([_tYear]);
          stubCompaniesThrows(
            _tYear.code,
            UnauthorizedException('Unauthorized'),
          );
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListStarted()),
        expect: () => [
          loadingState,
          isA<CompanyListState>()
              .having((s) => s.status, 'status', CompanyListStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'failure state carries the exception message',
        setUp: () {
          stubYearsThrows(
            ServerException('Internal Server Error', statusCode: 500),
          );
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListStarted()),
        expect: () => [
          loadingState,
          isA<CompanyListState>()
              .having((s) => s.status, 'status', CompanyListStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Internal Server Error',
              ),
        ],
      );
    });

    // ── CompanyListRefreshed ────────────────────────────────────────────
    group('on CompanyListRefreshed –', () {
      blocTest<CompanyListBloc, CompanyListState>(
        'emits [loading, success] with companies',
        setUp: () {
          stubYears([_tYear]);
          stubCompanies(_tYear.code, [_tCompany]);
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListRefreshed()),
        expect: () => [
          loadingState,
          const CompanyListState(
            status: CompanyListStatus.success,
            companies: [_tCompany],
            academicYears: [_tYear],
            selectedAcademicYear: _tYear,
          ),
        ],
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'emits [loading, failure] when repository throws',
        setUp: () {
          stubYearsThrows(NetworkException('No internet connection'));
        },
        build: buildBloc,
        act: (b) => b.add(const CompanyListRefreshed()),
        expect: () => [
          loadingState,
          isA<CompanyListState>().having(
            (s) => s.status,
            'status',
            CompanyListStatus.failure,
          ),
        ],
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'keeps previous companies in loading state then transitions to failure',
        build: buildBloc,
        seed: () => const CompanyListState(
          status: CompanyListStatus.success,
          companies: [_tCompany],
        ),
        act: (b) {
          when(
            () => academicYearRepo.getInternAcademicYears(),
          ).thenThrow(NetworkException('No internet connection'));
          b.add(const CompanyListRefreshed());
        },
        expect: () => [
          // loading keeps previous companies (status changes, companies unchanged)
          const CompanyListState(
            status: CompanyListStatus.loading,
            companies: [_tCompany],
          ),
          isA<CompanyListState>().having(
            (s) => s.status,
            'status',
            CompanyListStatus.failure,
          ),
        ],
      );
    });

    group('on CompanyListAcademicYearChanged –', () {
      blocTest<CompanyListBloc, CompanyListState>(
        'loads companies using the newly selected academic year code',
        setUp: () {
          stubCompanies(_tOtherYear.code, [_tCompany]);
        },
        build: buildBloc,
        seed: () => const CompanyListState(
          status: CompanyListStatus.success,
          academicYears: [_tYear, _tOtherYear],
          selectedAcademicYear: _tYear,
        ),
        act: (b) => b.add(const CompanyListAcademicYearChanged(_tOtherYear)),
        expect: () => [
          const CompanyListState(
            status: CompanyListStatus.loading,
            academicYears: [_tYear, _tOtherYear],
            selectedAcademicYear: _tOtherYear,
          ),
          const CompanyListState(
            status: CompanyListStatus.success,
            companies: [_tCompany],
            academicYears: [_tYear, _tOtherYear],
            selectedAcademicYear: _tOtherYear,
          ),
        ],
        verify: (_) {
          verify(
            () => companyRepo.getCompanies(academicYearCode: _tOtherYear.code),
          ).called(1);
          verifyNever(() => academicYearRepo.getInternAcademicYears());
        },
      );

      blocTest<CompanyListBloc, CompanyListState>(
        'does not reload when the selected academic year is unchanged',
        build: buildBloc,
        seed: () => const CompanyListState(
          status: CompanyListStatus.success,
          academicYears: [_tYear],
          selectedAcademicYear: _tYear,
        ),
        act: (b) => b.add(const CompanyListAcademicYearChanged(_tYear)),
        expect: () => <CompanyListState>[],
        verify: (_) {
          verifyNever(
            () => companyRepo.getCompanies(
              academicYearCode: any(named: 'academicYearCode'),
              search: any(named: 'search'),
            ),
          );
        },
      );
    });

    // ── State helpers ───────────────────────────────────────────────────
    group('CompanyListState helpers –', () {
      test('hasCompanies is false when companies is empty', () {
        const s = CompanyListState(
          status: CompanyListStatus.success,
          companies: [],
        );
        expect(s.hasCompanies, isFalse);
      });

      test('hasCompanies is true when companies is non-empty', () {
        const s = CompanyListState(
          status: CompanyListStatus.success,
          companies: [_tCompany],
        );
        expect(s.hasCompanies, isTrue);
      });

      test(
        'copyWith preserves existing errorMessage when not explicitly set',
        () {
          const s = CompanyListState(
            status: CompanyListStatus.failure,
            errorMessage: 'old error',
          );
          final updated = s.copyWith(status: CompanyListStatus.loading);
          expect(updated.errorMessage, 'old error');
        },
      );

      test('copyWith can explicitly clear errorMessage to null', () {
        const s = CompanyListState(
          status: CompanyListStatus.failure,
          errorMessage: 'old error',
        );
        // ignore: avoid_redundant_argument_values
        final updated = s.copyWith(
          status: CompanyListStatus.loading,
          errorMessage: null,
        );
        expect(updated.errorMessage, isNull);
      });
    });
  });
}

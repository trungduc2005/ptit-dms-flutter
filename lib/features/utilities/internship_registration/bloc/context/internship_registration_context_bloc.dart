import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/data/models/academic_year_option_model.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';
import 'package:ptit_dms_flutter/data/models/current_intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/eligibility_model.dart';
import 'package:ptit_dms_flutter/data/models/timeline_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/academic_year_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/company_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/eligibility_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

import 'internship_registration_context_event.dart';
import 'internship_registration_context_state.dart';

export 'internship_registration_context_event.dart';
export 'internship_registration_context_state.dart';

class InternshipRegistrationContextBloc extends Bloc<
    InternshipRegistrationContextEvent, InternshipRegistrationContextState> {
  InternshipRegistrationContextBloc({
    required AcademicYearRepository academicYearRepository,
    required EligibilityRepository eligibilityRepository,
    required TimelineRepository timelineRepository,
    required InternRegistrationRepository internRegistrationRepository,
    required CompanyRepository companyRepository,
  })  : _academicYearRepository = academicYearRepository,
        _eligibilityRepository = eligibilityRepository,
        _timelineRepository = timelineRepository,
        _internRegistrationRepository = internRegistrationRepository,
        _companyRepository = companyRepository,
        super(const InternshipRegistrationContextState()) {
    on<InternshipRegistrationContextStarted>(_onStarted);
    on<InternshipRegistrationAcademicYearSelected>(_onAcademicYearSelected);
    on<InternshipRegistrationContextRefreshed>(_onRefreshed);
  }

  final AcademicYearRepository _academicYearRepository;
  final EligibilityRepository _eligibilityRepository;
  final TimelineRepository _timelineRepository;
  final InternRegistrationRepository _internRegistrationRepository;
  final CompanyRepository _companyRepository;

  Future<void> _onStarted(
    InternshipRegistrationContextStarted event,
    Emitter<InternshipRegistrationContextState> emit,
  ) async {
    emit(
      state.copyWith(
        status: InternshipRegistrationContextStatus.loading,
        studentId: event.studentId.trim(),
        hasRegistered: false,
        isCheckingRegistrationStatus: true,
        currentRegistration: null,
        registrationTimeline: null,
        expectedInternshipPeriodTimeline: null,
        preferredCompanyCount: 0,
        isRegistrationOpen: false,
        mode: InternshipRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      final academicYears =
          await _academicYearRepository.getInternAcademicYears();

      if (emit.isDone || isClosed) return;

      final selectedAcademicYearId = _resolveSelectedAcademicYearId(
        academicYears: academicYears,
        preferredId: event.initialAcademicYearId,
        fallbackId: state.selectedAcademicYearId,
      );

      if (selectedAcademicYearId == null) {
        emit(
          state.copyWith(
            status: InternshipRegistrationContextStatus.success,
            academicYears: academicYears,
            selectedAcademicYearId: null,
            eligibility: null,
            timelines: const [],
            companies: const [],
            hasRegistered: false,
            isCheckingRegistrationStatus: false,
            currentRegistration: null,
            registrationTimeline: null,
            expectedInternshipPeriodTimeline: null,
            preferredCompanyCount: 0,
            isRegistrationOpen: false,
            mode: InternshipRegistrationMode.create,
            errorMessage: null,
          ),
        );
        return;
      }

      await _loadContextForAcademicYear(
        emit,
        academicYears: academicYears,
        academicYearId: selectedAcademicYearId,
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: InternshipRegistrationContextStatus.failure,
          isCheckingRegistrationStatus: false,
          errorMessage: _readErrorMessage(e),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: InternshipRegistrationContextStatus.failure,
          isCheckingRegistrationStatus: false,
          errorMessage: 'Khong the tai du lieu dang ky thuc tap.',
        ),
      );
    }
  }

  Future<void> _onAcademicYearSelected(
    InternshipRegistrationAcademicYearSelected event,
    Emitter<InternshipRegistrationContextState> emit,
  ) async {
    if (state.academicYears.isEmpty) {
      add(
        InternshipRegistrationContextStarted(
          studentId: state.studentId,
          initialAcademicYearId: event.academicYearId,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: InternshipRegistrationContextStatus.loading,
        selectedAcademicYearId: event.academicYearId,
        hasRegistered: false,
        isCheckingRegistrationStatus: true,
        currentRegistration: null,
        registrationTimeline: null,
        expectedInternshipPeriodTimeline: null,
        preferredCompanyCount: 0,
        isRegistrationOpen: false,
        mode: InternshipRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      await _loadContextForAcademicYear(
        emit,
        academicYears: state.academicYears,
        academicYearId: event.academicYearId,
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: InternshipRegistrationContextStatus.failure,
          isCheckingRegistrationStatus: false,
          errorMessage: _readErrorMessage(e),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: InternshipRegistrationContextStatus.failure,
          isCheckingRegistrationStatus: false,
          errorMessage: 'Khong the tai du lieu nam hoc da chon.',
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    InternshipRegistrationContextRefreshed event,
    Emitter<InternshipRegistrationContextState> emit,
  ) async {
    final academicYearId = state.selectedAcademicYearId;

    if (academicYearId == null || academicYearId.isEmpty) {
      add(
        InternshipRegistrationContextStarted(
          studentId: state.studentId,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: InternshipRegistrationContextStatus.loading,
        hasRegistered: false,
        isCheckingRegistrationStatus: true,
        currentRegistration: null,
        registrationTimeline: null,
        expectedInternshipPeriodTimeline: null,
        preferredCompanyCount: 0,
        isRegistrationOpen: false,
        mode: InternshipRegistrationMode.create,
        errorMessage: null,
      ),
    );

    try {
      await _loadContextForAcademicYear(
        emit,
        academicYears: state.academicYears,
        academicYearId: academicYearId,
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: InternshipRegistrationContextStatus.failure,
          isCheckingRegistrationStatus: false,
          errorMessage: _readErrorMessage(e),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: InternshipRegistrationContextStatus.failure,
          isCheckingRegistrationStatus: false,
          errorMessage: 'Khong the lam moi du lieu dang ky thuc tap.',
        ),
      );
    }
  }

  Future<void> _loadContextForAcademicYear(
    Emitter<InternshipRegistrationContextState> emit, {
    required List<AcademicYearOptionModel> academicYears,
    required String academicYearId,
  }) async {
    final results = await Future.wait<Object?>([
      _eligibilityRepository.getRegistrationEligibility(
        academicYearId: academicYearId,
      ),
      _timelineRepository.getInternTimelines(
        academicYearId: academicYearId,
      ),
      _companyRepository.getCompanies(),
      _loadRegistrationSnapshot(
        academicYearId: academicYearId,
        studentId: state.studentId,
      ),
    ]);

    if (emit.isDone || isClosed) return;

    final eligibility = results[0] as EligibilityModel;
    final timelines = results[1] as List<TimelineModel>;
    final companies = _filterCompaniesByAcademicYear(
      results[2] as List<CompanyModel>,
      academicYearId,
    );
    final registrationSnapshot = results[3] as _RegistrationSnapshot;

    final registrationTimeline = _findTimelineByType(
      timelines,
      'internshipRegistration',
    );
    final expectedInternshipPeriodTimeline = _findTimelineByType(
      timelines,
      'expectedInternshipPeriod',
    );

    emit(
      state.copyWith(
        status: InternshipRegistrationContextStatus.success,
        academicYears: academicYears,
        selectedAcademicYearId: academicYearId,
        eligibility: eligibility,
        timelines: timelines,
        companies: companies,
        hasRegistered: registrationSnapshot.hasRegistered,
        isCheckingRegistrationStatus: false,
        currentRegistration: registrationSnapshot.currentRegistration,
        registrationTimeline: registrationTimeline,
        expectedInternshipPeriodTimeline: expectedInternshipPeriodTimeline,
        preferredCompanyCount:
            registrationTimeline?.preferredCompanyCount ?? 0,
        isRegistrationOpen: _isRegistrationOpen(registrationTimeline),
        mode: _resolveMode(
          hasRegistered: registrationSnapshot.hasRegistered,
          registration: registrationSnapshot.currentRegistration,
        ),
        errorMessage: null,
      ),
    );
  }

  Future<_RegistrationSnapshot> _loadRegistrationSnapshot({
    required String academicYearId,
    required String studentId,
  }) async {
    final normalizedStudentId = studentId.trim();

    if (normalizedStudentId.isEmpty) {
      return const _RegistrationSnapshot();
    }

    final registrationCheck =
        await _internRegistrationRepository.checkInternRegistration(
      studentId: normalizedStudentId,
      academicYearId: academicYearId,
    );

    if (!registrationCheck.isRegistered) {
      return const _RegistrationSnapshot();
    }

    final currentRegistration =
        await _internRegistrationRepository.getCurrentRegistration(
      academicYearId: academicYearId,
    );

    return _RegistrationSnapshot(
      hasRegistered: true,
      currentRegistration: currentRegistration,
    );
  }

  List<CompanyModel> _filterCompaniesByAcademicYear(
    List<CompanyModel> companies,
    String academicYearId,
  ) {
    return companies.where((item) {
      final ref = item.academicYearRef;
      return ref == null || ref.isEmpty || ref == academicYearId;
    }).toList(growable: false);
  }

  String? _resolveSelectedAcademicYearId({
    required List<AcademicYearOptionModel> academicYears,
    String? preferredId,
    String? fallbackId,
  }) {
    final candidates = [preferredId, fallbackId];

    for (final candidate in candidates) {
      if (candidate == null || candidate.isEmpty) continue;
      final exists = academicYears.any((item) => item.id == candidate);
      if (exists) return candidate;
    }

    if (academicYears.isEmpty) {
      return null;
    }

    return academicYears.first.id;
  }

  TimelineModel? _findTimelineByType(
    List<TimelineModel> timelines,
    String type,
  ) {
    for (final item in timelines) {
      if (item.type == type) {
        return item;
      }
    }
    return null;
  }

  bool _isRegistrationOpen(TimelineModel? timeline) {
    final start = timeline?.startTime;
    final end = timeline?.endTime;

    if (start == null || end == null) {
      return false;
    }

    final now = DateTime.now();
    return !now.isBefore(start) && !now.isAfter(end);
  }

  InternshipRegistrationMode _resolveMode({
    required bool hasRegistered,
    required CurrentInternRegistrationModel? registration,
  }) {
    if (!hasRegistered || registration == null) {
      return InternshipRegistrationMode.create;
    }

    if (registration.type == 'facultyAssign') {
      return InternshipRegistrationMode.view;
    }

    final status = registration.status;
    if (registration.type == 'yourself' &&
        (status == 'approved' || status == 'assigned')) {
      return InternshipRegistrationMode.view;
    }

    return InternshipRegistrationMode.edit;
  }

  String _readErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return error.message ?? 'Khong the tai du lieu dang ky thuc tap.';
  }
}

final class _RegistrationSnapshot {
  const _RegistrationSnapshot({
    this.hasRegistered = false,
    this.currentRegistration,
  });

  final bool hasRegistered;
  final CurrentInternRegistrationModel? currentRegistration;
}

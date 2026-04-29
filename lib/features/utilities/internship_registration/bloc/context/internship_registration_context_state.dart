import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/academic_year_option.dart';
import 'package:ptit_dms_flutter/domain/entities/company.dart';
import 'package:ptit_dms_flutter/domain/entities/current_intern_registration.dart';
import 'package:ptit_dms_flutter/domain/entities/eligibility.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';

enum InternshipRegistrationContextStatus { initial, loading, success, failure }

enum InternshipRegistrationMode { create, edit, view }

const _unset = Object();

final class InternshipRegistrationContextState extends Equatable {
  const InternshipRegistrationContextState({
    this.status = InternshipRegistrationContextStatus.initial,
    this.studentId = '',
    this.academicYears = const [],
    this.selectedAcademicYearId,
    this.eligibility,
    this.timelines = const [],
    this.companies = const [],
    this.hasRegistered = false,
    this.isCheckingRegistrationStatus = false,
    this.currentRegistration,
    this.registrationTimeline,
    this.expectedInternshipPeriodTimeline,
    this.preferredCompanyCount = 0,
    this.isRegistrationOpen = false,
    this.mode = InternshipRegistrationMode.create,
    this.errorMessage,
  });

  final InternshipRegistrationContextStatus status;
  final String studentId;
  final List<AcademicYearOption> academicYears;
  final String? selectedAcademicYearId;
  final Eligibility? eligibility;
  final List<Timeline> timelines;
  final List<Company> companies;
  final bool hasRegistered;
  final bool isCheckingRegistrationStatus;
  final CurrentInternRegistration? currentRegistration;
  final Timeline? registrationTimeline;
  final Timeline? expectedInternshipPeriodTimeline;
  final int preferredCompanyCount;
  final bool isRegistrationOpen;
  final InternshipRegistrationMode mode;
  final String? errorMessage;

  bool get hasStudentId => studentId.trim().isNotEmpty;

  bool get hasRegister => hasRegistered;

  bool get hasCurrentRegistration => currentRegistration != null;

  bool get hasCompanies => companies.isNotEmpty;

  bool get canRegisterInternship => eligibility?.canRegisterInternship ?? false;

  bool get isEligibleForInternship => canRegisterInternship;

  bool get isInRegistrationWindow => isRegistrationOpen;

  bool get isViewOnly => mode == InternshipRegistrationMode.view;

  bool get canCreateRegistration =>
      isEligibleForInternship &&
      isInRegistrationWindow &&
      !hasRegistered &&
      !isCheckingRegistrationStatus;

  bool get canEditRegistration =>
      hasCurrentRegistration &&
      !isViewOnly &&
      isInRegistrationWindow &&
      !isCheckingRegistrationStatus;

  int get preferredCompanySlots =>
      preferredCompanyCount < 0 ? 0 : preferredCompanyCount;

  InternshipRegistrationContextState copyWith({
    InternshipRegistrationContextStatus? status,
    String? studentId,
    List<AcademicYearOption>? academicYears,
    Object? selectedAcademicYearId = _unset,
    Object? eligibility = _unset,
    List<Timeline>? timelines,
    List<Company>? companies,
    bool? hasRegistered,
    bool? isCheckingRegistrationStatus,
    Object? currentRegistration = _unset,
    Object? registrationTimeline = _unset,
    Object? expectedInternshipPeriodTimeline = _unset,
    int? preferredCompanyCount,
    bool? isRegistrationOpen,
    InternshipRegistrationMode? mode,
    Object? errorMessage = _unset,
  }) {
    return InternshipRegistrationContextState(
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      academicYears: academicYears ?? this.academicYears,
      selectedAcademicYearId: identical(selectedAcademicYearId, _unset)
          ? this.selectedAcademicYearId
          : selectedAcademicYearId as String?,
      eligibility: identical(eligibility, _unset)
          ? this.eligibility
          : eligibility as Eligibility?,
      timelines: timelines ?? this.timelines,
      companies: companies ?? this.companies,
      hasRegistered: hasRegistered ?? this.hasRegistered,
      isCheckingRegistrationStatus:
          isCheckingRegistrationStatus ?? this.isCheckingRegistrationStatus,
      currentRegistration: identical(currentRegistration, _unset)
          ? this.currentRegistration
          : currentRegistration as CurrentInternRegistration?,
      registrationTimeline: identical(registrationTimeline, _unset)
          ? this.registrationTimeline
          : registrationTimeline as Timeline?,
      expectedInternshipPeriodTimeline:
          identical(expectedInternshipPeriodTimeline, _unset)
          ? this.expectedInternshipPeriodTimeline
          : expectedInternshipPeriodTimeline as Timeline?,
      preferredCompanyCount:
          preferredCompanyCount ?? this.preferredCompanyCount,
      isRegistrationOpen: isRegistrationOpen ?? this.isRegistrationOpen,
      mode: mode ?? this.mode,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    studentId,
    academicYears,
    selectedAcademicYearId,
    eligibility,
    timelines,
    companies,
    hasRegistered,
    isCheckingRegistrationStatus,
    currentRegistration,
    registrationTimeline,
    expectedInternshipPeriodTimeline,
    preferredCompanyCount,
    isRegistrationOpen,
    mode,
    errorMessage,
  ];
}

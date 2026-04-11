import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/academic_year_option_model.dart';
import 'package:ptit_dms_flutter/data/models/company_model.dart';
import 'package:ptit_dms_flutter/data/models/current_intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/eligibility_model.dart';
import 'package:ptit_dms_flutter/data/models/timeline_model.dart';

enum InternshipRegistrationContextStatus {
  initial,
  loading,
  success,
  failure,
}

enum InternshipRegistrationMode {
  create,
  edit,
  view,
}

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
  final List<AcademicYearOptionModel> academicYears;
  final String? selectedAcademicYearId;
  final EligibilityModel? eligibility;
  final List<TimelineModel> timelines;
  final List<CompanyModel> companies;
  final bool hasRegistered;
  final bool isCheckingRegistrationStatus;
  final CurrentInternRegistrationModel? currentRegistration;
  final TimelineModel? registrationTimeline;
  final TimelineModel? expectedInternshipPeriodTimeline;
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
    List<AcademicYearOptionModel>? academicYears,
    Object? selectedAcademicYearId = _unset,
    Object? eligibility = _unset,
    List<TimelineModel>? timelines,
    List<CompanyModel>? companies,
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
          : eligibility as EligibilityModel?,
      timelines: timelines ?? this.timelines,
      companies: companies ?? this.companies,
      hasRegistered: hasRegistered ?? this.hasRegistered,
      isCheckingRegistrationStatus:
          isCheckingRegistrationStatus ?? this.isCheckingRegistrationStatus,
      currentRegistration: identical(currentRegistration, _unset)
          ? this.currentRegistration
          : currentRegistration as CurrentInternRegistrationModel?,
      registrationTimeline: identical(registrationTimeline, _unset)
          ? this.registrationTimeline
          : registrationTimeline as TimelineModel?,
      expectedInternshipPeriodTimeline:
          identical(expectedInternshipPeriodTimeline, _unset)
              ? this.expectedInternshipPeriodTimeline
              : expectedInternshipPeriodTimeline as TimelineModel?,
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

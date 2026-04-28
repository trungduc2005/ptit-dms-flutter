import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';

sealed class InternshipRegistrationSubmitEvent extends Equatable {
  const InternshipRegistrationSubmitEvent();

  @override
  List<Object?> get props => [];
}

final class InternshipCvUploadRequested
    extends InternshipRegistrationSubmitEvent {
  const InternshipCvUploadRequested({
    required this.academicYearId,
    required this.filePath,
    this.studentId, 
  });

  final String academicYearId;
  final String filePath;
  final String? studentId;

  @override
  List<Object?> get props => [academicYearId, filePath, studentId];
}

final class InternshipRegistrationSubmitted
    extends InternshipRegistrationSubmitEvent {
  const InternshipRegistrationSubmitted({
    required this.request,
    required this.expectedPreferredCompanyCount,
  });

  final InternRegistrationRequestModel request;
  final int expectedPreferredCompanyCount;

  @override
  List<Object?> get props => [
        request,
        expectedPreferredCompanyCount,
      ];
}

final class InternshipRegistrationUpdated
    extends InternshipRegistrationSubmitEvent {
  const InternshipRegistrationUpdated({
    required this.request,
    required this.expectedPreferredCompanyCount,
    this.allowMissingCv = true,
  });

  final InternRegistrationRequestModel request;
  final int expectedPreferredCompanyCount;
  final bool allowMissingCv;

  @override
  List<Object?> get props => [
        request,
        expectedPreferredCompanyCount,
        allowMissingCv,
      ];
}

final class InternshipRegistrationSubmitStateCleared
    extends InternshipRegistrationSubmitEvent {
  const InternshipRegistrationSubmitStateCleared();
}

final class InternshipUploadedCvCleared
    extends InternshipRegistrationSubmitEvent {
  const InternshipUploadedCvCleared();
}

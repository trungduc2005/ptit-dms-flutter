import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_cv_upload_result.dart';
import 'package:ptit_dms_flutter/domain/entities/intern_registration.dart';

enum InternshipCvUploadStatus { initial, loading, success, failure }

enum InternshipRegistrationSubmitStatus { initial, loading, success, failure }

const _unset = Object();

final class InternshipRegistrationSubmitState extends Equatable {
  const InternshipRegistrationSubmitState({
    this.uploadStatus = InternshipCvUploadStatus.initial,
    this.submitStatus = InternshipRegistrationSubmitStatus.initial,
    this.uploadedCv,
    this.submittedRegistration,
    this.message,
  });

  final InternshipCvUploadStatus uploadStatus;
  final InternshipRegistrationSubmitStatus submitStatus;
  final InternCvUploadResult? uploadedCv;
  final InternRegistration? submittedRegistration;
  final String? message;

  bool get isBusy =>
      uploadStatus == InternshipCvUploadStatus.loading ||
      submitStatus == InternshipRegistrationSubmitStatus.loading;

  bool get hasUploadedCv =>
      (uploadedCv?.cvFileKey.trim().isNotEmpty ?? false) &&
      (uploadedCv?.cvFileName.trim().isNotEmpty ?? false);

  InternshipRegistrationSubmitState copyWith({
    InternshipCvUploadStatus? uploadStatus,
    InternshipRegistrationSubmitStatus? submitStatus,
    Object? uploadedCv = _unset,
    Object? submittedRegistration = _unset,
    Object? message = _unset,
  }) {
    return InternshipRegistrationSubmitState(
      uploadStatus: uploadStatus ?? this.uploadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      uploadedCv: identical(uploadedCv, _unset)
          ? this.uploadedCv
          : uploadedCv as InternCvUploadResult?,
      submittedRegistration: identical(submittedRegistration, _unset)
          ? this.submittedRegistration
          : submittedRegistration as InternRegistration?,
      message: identical(message, _unset) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [
    uploadStatus,
    submitStatus,
    uploadedCv,
    submittedRegistration,
    message,
  ];
}

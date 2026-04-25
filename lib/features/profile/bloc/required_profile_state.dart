import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/required_profile_check_model.dart';

enum RequiredProfileStatus {
  initial,
  checking,
  incomplete,
  complete,
  submitting,
  success,
  failure,
}

const _unset = Object();

final class RequiredProfileState extends Equatable {
  const RequiredProfileState({
    this.status = RequiredProfileStatus.initial,
    this.requirement,
    this.message,
  });

  final RequiredProfileStatus status;
  final RequiredProfileCheckModel? requirement;
  final String? message;

  bool get mustChangePassword => requirement?.mustChangePassword ?? false;
  RequiredProfileFieldsModel get fields =>
      requirement?.fields ?? const RequiredProfileFieldsModel();

  RequiredProfileState copyWith({
    RequiredProfileStatus? status,
    Object? requirement = _unset,
    Object? message = _unset,
  }) {
    return RequiredProfileState(
      status: status ?? this.status,
      requirement: identical(requirement, _unset)
          ? this.requirement
          : requirement as RequiredProfileCheckModel?,
      message: identical(message, _unset) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [status, requirement, message];
}

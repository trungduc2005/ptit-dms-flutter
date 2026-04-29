import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/required_profile_update_request.dart';

sealed class RequiredProfileEvent extends Equatable {
  const RequiredProfileEvent();

  @override
  List<Object?> get props => [];
}

final class RequiredProfileStarted extends RequiredProfileEvent {
  const RequiredProfileStarted();
}

final class RequiredProfileSubmitted extends RequiredProfileEvent {
  const RequiredProfileSubmitted({required this.request});

  final RequiredProfileUpdateRequest request;

  @override
  List<Object?> get props => [request];
}

final class RequiredProfileStateCleared extends RequiredProfileEvent {
  const RequiredProfileStateCleared();
}

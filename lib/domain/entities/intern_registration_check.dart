import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class InternRegistrationCheck extends Equatable {
  const InternRegistrationCheck({required this.isRegistered});

  final bool isRegistered;

  factory InternRegistrationCheck.fromJson(Map<String, dynamic> json) {
    return InternRegistrationCheck(
      isRegistered: asBool(json['register']) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'register': isRegistered};
  }

  @override
  List<Object?> get props => [isRegistered];
}

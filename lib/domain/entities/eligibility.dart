import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class Eligibility extends Equatable {
  const Eligibility({
    required this.canRegisterSpecialization,
    required this.canRegisterInternship,
  });

  final bool canRegisterSpecialization;
  final bool canRegisterInternship;

  factory Eligibility.fromJson(Map<String, dynamic> json) {
    return Eligibility(
      canRegisterSpecialization:
          asBool(json['canRegisterSpecialization']) ?? false,
      canRegisterInternship: asBool(json['canRegisterInternship']) ?? false,
    );
  }

  @override
  List<Object?> get props => [canRegisterSpecialization, canRegisterInternship];
}

import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class EligibilityModel extends Equatable {
  const EligibilityModel({
    required this.canRegisterSpecialization,
    required this.canRegisterInternship,
  });

  final bool canRegisterSpecialization;
  final bool canRegisterInternship;

  factory EligibilityModel.fromJson(Map<String, dynamic> json) {
    return EligibilityModel(
      canRegisterSpecialization:
          asBool(json['canRegisterSpecialization']) ?? false,
      canRegisterInternship:
          asBool(json['canRegisterInternship']) ?? false,
    );
  }

  @override
  List<Object?> get props => [
        canRegisterSpecialization,
        canRegisterInternship,
      ];
}

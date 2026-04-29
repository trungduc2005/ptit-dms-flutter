import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class RequiredProfileCheck extends Equatable {
  const RequiredProfileCheck({
    required this.isComplete,
    this.missingFields = const [],
    this.fields = const RequiredProfileFields(),
    this.mustChangePassword = false,
  });

  final bool isComplete;
  final List<String> missingFields;
  final RequiredProfileFields fields;
  final bool mustChangePassword;

  factory RequiredProfileCheck.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['data'] ?? json['requiredFields'];
    final missingJson = json['missingFields'];

    return RequiredProfileCheck(
      isComplete: asBool(json['isComplete']) ?? false,
      missingFields: missingJson is List
          ? missingJson.map((item) => item.toString()).toList(growable: false)
          : const [],
      fields: fieldsJson is Map
          ? RequiredProfileFields.fromJson(
              Map<String, dynamic>.from(fieldsJson),
            )
          : const RequiredProfileFields(),
      mustChangePassword: asBool(json['mustChangePassword']) ?? false,
    );
  }

  @override
  List<Object?> get props => [
    isComplete,
    missingFields,
    fields,
    mustChangePassword,
  ];
}

class RequiredProfileFields extends Equatable {
  const RequiredProfileFields({this.email, this.phone, this.citizenId});

  final String? email;
  final String? phone;
  final String? citizenId;

  factory RequiredProfileFields.fromJson(Map<String, dynamic> json) {
    return RequiredProfileFields(
      email: asString(json['email']),
      phone: asString(json['phone']),
      citizenId: asString(json['citizenId']),
    );
  }

  @override
  List<Object?> get props => [email, phone, citizenId];
}

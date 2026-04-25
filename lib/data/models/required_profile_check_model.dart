import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class RequiredProfileCheckModel extends Equatable {
  const RequiredProfileCheckModel({
    required this.isComplete,
    this.missingFields = const [],
    this.fields = const RequiredProfileFieldsModel(),
    this.mustChangePassword = false,
  });

  final bool isComplete;
  final List<String> missingFields;
  final RequiredProfileFieldsModel fields;
  final bool mustChangePassword;

  factory RequiredProfileCheckModel.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['data'] ?? json['requiredFields'];
    final missingJson = json['missingFields'];

    return RequiredProfileCheckModel(
      isComplete: asBool(json['isComplete']) ?? false,
      missingFields: missingJson is List
          ? missingJson.map((item) => item.toString()).toList(growable: false)
          : const [],
      fields: fieldsJson is Map
          ? RequiredProfileFieldsModel.fromJson(
              Map<String, dynamic>.from(fieldsJson),
            )
          : const RequiredProfileFieldsModel(),
      mustChangePassword: asBool(json['mustChangePassword']) ?? false,
    );
  }

  @override
  List<Object?> get props => [isComplete, missingFields, fields, mustChangePassword];
}

class RequiredProfileFieldsModel extends Equatable {
  const RequiredProfileFieldsModel({this.email, this.phone, this.citizenId});

  final String? email;
  final String? phone;
  final String? citizenId;

  factory RequiredProfileFieldsModel.fromJson(Map<String, dynamic> json) {
    return RequiredProfileFieldsModel(
      email: asString(json['email']),
      phone: asString(json['phone']),
      citizenId: asString(json['citizenId']),
    );
  }

  @override
  List<Object?> get props => [email, phone, citizenId];
}

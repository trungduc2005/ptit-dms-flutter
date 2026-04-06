import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class InternRegistrationCheckModel extends Equatable {
  const InternRegistrationCheckModel({
    required this.isRegistered,
  });

  final bool isRegistered;

  factory InternRegistrationCheckModel.fromJson(Map<String, dynamic> json) {
    return InternRegistrationCheckModel(
      isRegistered: asBool(json['register']) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'register': isRegistered,
    };
  }

  @override
  List<Object?> get props => [isRegistered];
}

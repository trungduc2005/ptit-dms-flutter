import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class AuthLoginResponseModel extends Equatable {
  const AuthLoginResponseModel({
    required this.success,
    this.message,
    this.userId,
    this.role,
  });

  final bool success;
  final String? message;
  final String? userId;
  final String? role;

  factory AuthLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponseModel(
      success: asBool(json['success']) ?? false,
      message: asString(json['message']),
      userId: asString(json['userId']),
      role: asString(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'userId': userId,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [success, message, userId, role];
}

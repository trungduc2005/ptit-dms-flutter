import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class AuthLoginResult extends Equatable {
  const AuthLoginResult({
    required this.success,
    this.message,
    this.userId,
    this.role,
  });

  final bool success;
  final String? message;
  final String? userId;
  final String? role;

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    return AuthLoginResult(
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

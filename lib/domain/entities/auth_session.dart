import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.valid, this.user});

  final bool valid;
  final AuthSessionUser? user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return AuthSession(
      valid: asBool(json['valid']) ?? false,
      user: userJson is Map
          ? AuthSessionUser.fromJson(Map<String, dynamic>.from(userJson))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'valid': valid, 'user': user?.toJson()};
  }

  @override
  List<Object?> get props => [valid, user];
}

class AuthSessionUser extends Equatable {
  const AuthSessionUser({
    this.userId,
    this.userCode,
    this.username,
    this.fullName,
    this.role,
    this.roleManagements = const [],
    this.issuedAt,
    this.expiresAt,
  });

  final String? userId;
  final String? userCode;
  final String? username;
  final String? fullName;
  final String? role;
  final List<String> roleManagements;
  final int? issuedAt;
  final int? expiresAt;

  factory AuthSessionUser.fromJson(Map<String, dynamic> json) {
    final roleManagementsJson = json['roleManagements'];

    return AuthSessionUser(
      userId: asString(json['userId']),
      userCode: asString(json['userCode']),
      username: asString(json['username']),
      fullName: asString(json['fullName']),
      role: asString(json['role']),
      roleManagements: roleManagementsJson is List
          ? roleManagementsJson
                .map((item) => item.toString())
                .toList(growable: false)
          : const [],
      issuedAt: asInt(json['iat']),
      expiresAt: asInt(json['exp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userCode': userCode,
      'username': username,
      'fullName': fullName,
      'role': role,
      'roleManagements': roleManagements,
      'iat': issuedAt,
      'exp': expiresAt,
    };
  }

  @override
  List<Object?> get props => [
    userId,
    userCode,
    username,
    fullName,
    role,
    roleManagements,
    issuedAt,
    expiresAt,
  ];
}

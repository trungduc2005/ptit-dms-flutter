import 'package:equatable/equatable.dart';

enum AuthStatus {
  loading,
  checking,
  initial,
  authenticated,
  unauthenticated,
  failure,
}

const _unset = Object();

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
    this.userId,
    this.role,
  });

  final AuthStatus status;
  final String? message;
  final String? userId;
  final String? role;

  AuthState copyWith({
    AuthStatus? status,
    Object? message = _unset,
    Object? userId = _unset,
    Object? role = _unset,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: identical(message, _unset) ? this.message : message as String?,
      userId: identical(userId, _unset) ? this.userId : userId as String?,
      role: identical(role, _unset) ? this.role : role as String?,
    );
  }

  @override
  List<Object?> get props => [status, message, userId, role];
}

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/domain/repositories/auth_repository.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_event.dart';
import 'package:ptit_dms_flutter/features/auth/bloc/auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.checking,
        message: null,
        userId: null,
        role: null,
      ),
    );

    try {
      final data = await _authRepository.checkSession();

      if (emit.isDone || isClosed) return;

      if (!data.valid) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            message: null,
            userId: null,
            role: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          message: null,
          userId: data.user?.userId,
          role: data.user?.role,
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      final statusCode = e.response?.statusCode;
      final message = statusCode == 401
          ? null
          : (e.message ?? 'Không thể kiểm tra phiên đăng nhập');

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          message: message,
          userId: null,
          role: null,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          message: 'Không thể kiểm tra phiên đăng nhập',
          userId: null,
          role: null,
        ),
      );
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        message: null,
        userId: null,
        role: null,
      ),
    );

    try {
      final data = await _authRepository.login(
        username: event.username,
        password: event.password,
      );

      if (emit.isDone || isClosed) return;

      if (!data.success) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: data.message ?? 'Đăng nhập thất bại',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          message: null,
          userId: data.userId,
          role: data.role,
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      final responseData = e.response?.data;
      final message = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : (e.message ?? 'Đăng nhập thất bại');

      emit(state.copyWith(status: AuthStatus.failure, message: message));
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Đăng nhập thất bại',
        ),
      );
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } catch (_) {}

    if (emit.isDone || isClosed) return;

    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        message: null,
        userId: null,
        role: null,
      ),
    );
  }
}

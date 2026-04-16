import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';

import 'profile_context_event.dart';
import 'profile_context_state.dart';

export 'profile_context_event.dart';
export 'profile_context_state.dart';

class ProfileContextBloc extends Bloc<ProfileContextEvent, ProfileContextState> {
  ProfileContextBloc(this._studentProfileRepository)
      : super(const ProfileContextState()) {
    on<ProfileContextStarted>(_onStarted);
    on<ProfileContextRefreshed>(_onRefreshed);
  }

  final StudentProfileRepository _studentProfileRepository;

  Future<void> _onStarted(
    ProfileContextStarted event,
    Emitter<ProfileContextState> emit,
  ) async {
    await _loadProfile(emit);
  }

  Future<void> _onRefreshed(
    ProfileContextRefreshed event,
    Emitter<ProfileContextState> emit,
  ) async {
    await _loadProfile(emit);
  }

  Future<void> _loadProfile(Emitter<ProfileContextState> emit) async {
    emit(
      state.copyWith(
        status: ProfileContextStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final profile = await _studentProfileRepository.getProfile();

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProfileContextStatus.success,
          profile: profile,
          errorMessage: null,
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProfileContextStatus.failure,
          errorMessage: _readErrorMessage(e),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: ProfileContextStatus.failure,
          errorMessage: 'Khong the tai thong tin ca nhan.',
        ),
      );
    }
  }

  String _readErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return error.message ?? 'Khong the tai thong tin ca nhan.';
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/data/models/student_profile_update_request_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';

import 'profile_submit_event.dart';
import 'profile_submit_state.dart';

export 'profile_submit_event.dart';
export 'profile_submit_state.dart';

class ProfileSubmitBloc extends Bloc<ProfileSubmitEvent, ProfileSubmitState> {
  ProfileSubmitBloc(this._studentProfileRepository)
      : super(const ProfileSubmitState()) {
    on<ProfileUpdateSubmitted>(_onProfileUpdateSubmitted);
    on<ProfileAvatarUploadRequested>(_onProfileAvatarUploadRequested);
    on<ProfileSubmitStateCleared>(_onProfileSubmitStateCleared);
  }

  final StudentProfileRepository _studentProfileRepository;

  Future<void> _onProfileUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileSubmitState> emit,
  ) async {
    final validationMessage = _validateRequest(event.request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          updatedProfile: null,
          message: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: ProfileSubmitStatus.loading,
        updatedProfile: null,
        message: null,
      ),
    );

    try {
      final updatedProfile = await _studentProfileRepository.updateProfile(
        request: event.request,
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.success,
          updatedProfile: updatedProfile,
          message: 'Cap nhat thong tin thanh cong.',
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          updatedProfile: null,
          message: _readErrorMessage(e, 'Cap nhat thong tin that bai.'),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          updatedProfile: null,
          message: 'Cap nhat thong tin that bai.',
        ),
      );
    }
  }

  Future<void> _onProfileAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileSubmitState> emit,
  ) async {
    final filePath = event.filePath.trim();
    if (filePath.isEmpty) {
      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          uploadedAvatar: null,
          message: 'Ban phai nhap duong dan file avatar.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        uploadStatus: ProfileAvatarUploadStatus.loading,
        uploadedAvatar: null,
        message: null,
      ),
    );

    try {
      final uploadedAvatar = await _studentProfileRepository.uploadAvatar(
        filePath: filePath,
      );

      if (emit.isDone || isClosed) return;

      if (!uploadedAvatar.success) {
        emit(
          state.copyWith(
            uploadStatus: ProfileAvatarUploadStatus.failure,
            uploadedAvatar: null,
            message: 'Upload avatar that bai.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.success,
          uploadedAvatar: uploadedAvatar,
          message: 'Upload avatar thanh cong.',
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          uploadedAvatar: null,
          message: _readErrorMessage(e, 'Upload avatar that bai.'),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          uploadedAvatar: null,
          message: 'Upload avatar that bai.',
        ),
      );
    }
  }

  void _onProfileSubmitStateCleared(
    ProfileSubmitStateCleared event,
    Emitter<ProfileSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        submitStatus: ProfileSubmitStatus.initial,
        uploadStatus: ProfileAvatarUploadStatus.initial,
        updatedProfile: null,
        uploadedAvatar: null,
        message: null,
      ),
    );
  }

  String? _validateRequest(StudentProfileUpdateRequestModel request) {
    final email = request.email?.trim() ?? '';
    final phone = request.phone?.trim() ?? '';

    if (email.isNotEmpty && !_isValidEmail(email)) {
      return 'Email khong hop le.';
    }

    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      return 'So dien thoai khong hop le.';
    }

    return null;
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    return RegExp(r'^\d{10}$').hasMatch(value);
  }

  String _readErrorMessage(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return error.message ?? fallback;
  }
}

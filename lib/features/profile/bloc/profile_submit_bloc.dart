import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';
import 'package:ptit_dms_flutter/domain/entities/student_profile_update_request.dart';
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
          message: 'Cập nhật thông tin thành công.',
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          updatedProfile: null,
          message: readDioErrorMessage(
            e,
            fallback: 'Cập nhật thông tin thất bại.',
          ),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          updatedProfile: null,
          message: 'Cập nhật thông tin thất bại.',
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
          message: 'Bạn phải nhập đường dẫn file avatar.',
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
            message: 'Upload avatar thất bại.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.success,
          uploadedAvatar: uploadedAvatar,
          message: 'Upload avatar thành công.',
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          uploadedAvatar: null,
          message: readDioErrorMessage(e, fallback: 'Upload avatar thất bại.'),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: ProfileAvatarUploadStatus.failure,
          uploadedAvatar: null,
          message: 'Upload avatar thất bại.',
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

  String? _validateRequest(StudentProfileUpdateRequest request) {
    final email = request.email?.trim() ?? '';
    final phone = request.phone?.trim() ?? '';

    if (email.isNotEmpty && !_isValidEmail(email)) {
      return 'Email không hợp lệ.';
    }

    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      return 'Số điện thoại không hợp lệ.';
    }

    return null;
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    return RegExp(r'^\d{10}$').hasMatch(value);
  }
}

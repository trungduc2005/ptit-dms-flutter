import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/data/models/required_profile_update_request_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/student_profile_repository.dart';

import 'required_profile_event.dart';
import 'required_profile_state.dart';

export 'required_profile_event.dart';
export 'required_profile_state.dart';

class RequiredProfileBloc
    extends Bloc<RequiredProfileEvent, RequiredProfileState> {
  RequiredProfileBloc(this._repository) : super(const RequiredProfileState()) {
    on<RequiredProfileStarted>(_onStarted);
    on<RequiredProfileSubmitted>(_onSubmitted);
    on<RequiredProfileStateCleared>(_onCleared);
  }

  final StudentProfileRepository _repository;

  Future<void> _onStarted(
    RequiredProfileStarted event,
    Emitter<RequiredProfileState> emit,
  ) async {
    emit(state.copyWith(status: RequiredProfileStatus.checking, message: null));

    try {
      final requirement = await _repository.checkRequiredProfile();
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          status: requirement.isComplete
              ? RequiredProfileStatus.complete
              : RequiredProfileStatus.incomplete,
          requirement: requirement,
          message: null,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(
        status: RequiredProfileStatus.failure,
        message: _readErrorMessage(e, 'Không thể kiểm tra thông tin bắt buộc.'),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: RequiredProfileStatus.failure,
        message: 'Không thể kiểm tra thông tin bắt buộc.',
      ));
    }
  }

  Future<void> _onSubmitted(
    RequiredProfileSubmitted event,
    Emitter<RequiredProfileState> emit,
  ) async {
    final validationMessage = _validateRequest(
      event.request,
      mustChangePassword: state.mustChangePassword,
    );

    if (validationMessage != null) {
      emit(state.copyWith(
        status: RequiredProfileStatus.failure,
        message: validationMessage,
      ));
      return;
    }

    emit(state.copyWith(status: RequiredProfileStatus.submitting, message: null));

    try {
      await _repository.updateRequiredProfile(request: event.request);
      if (emit.isDone || isClosed) return;

      emit(state.copyWith(
        status: RequiredProfileStatus.success,
        message: 'Cập nhật thông tin thành công.',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: RequiredProfileStatus.failure,
        message: _readErrorMessage(e, 'Cập nhật thông tin thất bại.'),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: RequiredProfileStatus.failure,
        message: 'Cập nhật thông tin thất bại.',
      ));
    }
  }

  void _onCleared(
    RequiredProfileStateCleared event,
    Emitter<RequiredProfileState> emit,
  ) {
    emit(const RequiredProfileState());
  }

  String? _validateRequest(
    RequiredProfileUpdateRequestModel request, {
    required bool mustChangePassword,
  }) {
    final email = request.email.trim();
    final phone = request.phone.trim();
    final citizenId = request.citizenId.trim();

    if (email.isEmpty || !_isValidEmail(email)) return 'Email không hợp lệ.';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) return 'Số điện thoại không hợp lệ.';
    if (!RegExp(r'^\d{12}$').hasMatch(citizenId)) return 'Số CCCD không hợp lệ.';

    if (mustChangePassword) {
      final newPassword = request.newPassword ?? '';
      final confirmPassword = request.confirmPassword ?? '';

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        return 'Bạn phải nhập mật khẩu mới.';
      }
      if (newPassword != confirmPassword) return 'Mật khẩu xác nhận không khớp.';
      if (newPassword.length < 8 || RegExp(r'\s').hasMatch(newPassword)) {
        return 'Mật khẩu phải có ít nhất 8 ký tự và không chứa khoảng trắng.';
      }
    }

    return null;
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  String _readErrorMessage(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return error.message ?? fallback;
  }
}
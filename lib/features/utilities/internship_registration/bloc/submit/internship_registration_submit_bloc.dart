import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/utils/error_helpers.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';

import 'internship_registration_submit_event.dart';
import 'internship_registration_submit_state.dart';

export 'internship_registration_submit_event.dart';
export 'internship_registration_submit_state.dart';

class InternshipRegistrationSubmitBloc
    extends
        Bloc<
          InternshipRegistrationSubmitEvent,
          InternshipRegistrationSubmitState
        > {
  InternshipRegistrationSubmitBloc({
    required InternCvRepository internCvRepository,
    required InternRegistrationRepository internRegistrationRepository,
  }) : _internCvRepository = internCvRepository,
       _internRegistrationRepository = internRegistrationRepository,
       super(const InternshipRegistrationSubmitState()) {
    on<InternshipCvUploadRequested>(_onCvUploadRequested);
    on<InternshipRegistrationSubmitted>(_onRegistrationSubmitted);
    on<InternshipRegistrationUpdated>(_onRegistrationUpdated);
    on<InternshipRegistrationSubmitStateCleared>(_onSubmitStateCleared);
    on<InternshipUploadedCvCleared>(_onUploadedCvCleared);
  }

  final InternCvRepository _internCvRepository;
  final InternRegistrationRepository _internRegistrationRepository;

  Future<void> _onCvUploadRequested(
    InternshipCvUploadRequested event,
    Emitter<InternshipRegistrationSubmitState> emit,
  ) async {
    emit(
      state.copyWith(
        uploadStatus: InternshipCvUploadStatus.loading,
        uploadedCv: null,
        message: null,
      ),
    );

    try {
      final uploadedCv = await _internCvRepository.uploadCv(
        academicYearId: event.academicYearId,
        filePath: event.filePath,
        studentId: event.studentId,
      );

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: InternshipCvUploadStatus.success,
          uploadedCv: uploadedCv,
          message: 'Upload CV thành công.',
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: InternshipCvUploadStatus.failure,
          uploadedCv: null,
          message: readDioErrorMessage(e, fallback: 'Upload CV thất bại.'),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: InternshipCvUploadStatus.failure,
          uploadedCv: null,
          message: 'Upload CV thất bại.',
        ),
      );
    }
  }

  Future<void> _onRegistrationSubmitted(
    InternshipRegistrationSubmitted event,
    Emitter<InternshipRegistrationSubmitState> emit,
  ) async {
    await _submitRegistration(
      emit,
      request: event.request,
      expectedPreferredCompanyCount: event.expectedPreferredCompanyCount,
      allowMissingCv: false,
      action: () => _internRegistrationRepository.registerInternship(
        request: event.request,
      ),
      successMessage: 'Đăng ký thực tập thành công.',
      failureMessage: 'Đăng ký thực tập thất bại.',
    );
  }

  Future<void> _onRegistrationUpdated(
    InternshipRegistrationUpdated event,
    Emitter<InternshipRegistrationSubmitState> emit,
  ) async {
    await _submitRegistration(
      emit,
      request: event.request,
      expectedPreferredCompanyCount: event.expectedPreferredCompanyCount,
      allowMissingCv: event.allowMissingCv,
      action: () => _internRegistrationRepository.updateInternship(
        request: event.request,
      ),
      successMessage: 'Cập nhật đăng ký thực tập thành công.',
      failureMessage: 'Cập nhật đăng ký thực tập thất bại.',
    );
  }

  Future<void> _submitRegistration(
    Emitter<InternshipRegistrationSubmitState> emit, {
    required InternRegistrationRequestModel request,
    required int expectedPreferredCompanyCount,
    required bool allowMissingCv,
    required Future<InternRegistrationModel> Function() action,
    required String successMessage,
    required String failureMessage,
  }) async {
    final validationMessage = _validateRequest(
      request,
      expectedPreferredCompanyCount: expectedPreferredCompanyCount,
      allowMissingCv: allowMissingCv,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          submitStatus: InternshipRegistrationSubmitStatus.failure,
          message: validationMessage,
          submittedRegistration: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: InternshipRegistrationSubmitStatus.loading,
        message: null,
        submittedRegistration: null,
      ),
    );

    try {
      final registration = await action();

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: InternshipRegistrationSubmitStatus.success,
          submittedRegistration: registration,
          message: successMessage,
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: InternshipRegistrationSubmitStatus.failure,
          message: readDioErrorMessage(e, fallback: failureMessage),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          submitStatus: InternshipRegistrationSubmitStatus.failure,
          message: failureMessage,
        ),
      );
    }
  }

  String? _validateRequest(
    InternRegistrationRequestModel request, {
    required int expectedPreferredCompanyCount,
    required bool allowMissingCv,
  }) {
    if (request.academicYearId.trim().isEmpty) {
      return 'Thiếu năm học đăng ký.';
    }

    final cvFileKey = request.cvFileKey.trim();
    final cvFileName = request.cvFileName.trim();

    if (allowMissingCv) {
      final hasAnyCvValue = cvFileKey.isNotEmpty || cvFileName.isNotEmpty;
      final hasFullCvValue = cvFileKey.isNotEmpty && cvFileName.isNotEmpty;

      if (hasAnyCvValue && !hasFullCvValue) {
        return 'Thông tin CV không hợp lệ.';
      }
    } else {
      if (cvFileKey.isEmpty || cvFileName.isEmpty) {
        return 'Bạn phải upload CV trước khi gửi đăng ký.';
      }
    }

    if (request.cpa < 0 || request.cpa > 4) {
      return 'CPA phải nằm trong khoảng 0 - 4.';
    }

    if (request is RegisterWishInternRequestModel) {
      if (expectedPreferredCompanyCount <= 0) {
        return 'Chưa có cấu hình số lượng nguyện vọng đăng ký.';
      }

      if (request.preferredCompanies.length != expectedPreferredCompanyCount) {
        return 'Bạn phải chọn đủ $expectedPreferredCompanyCount doanh nghiệp nguyện vọng.';
      }

      final normalized = request.preferredCompanies
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);

      if (normalized.length != request.preferredCompanies.length) {
        return 'Danh sách doanh nghiệp nguyện vọng không hợp lệ.';
      }

      if (normalized.toSet().length != normalized.length) {
        return 'Các nguyện vọng doanh nghiệp không được trùng nhau.';
      }
    }

    if (request is RegisterYourselfInternRequestModel) {
      if (request.companyName.trim().isEmpty ||
          request.companyField.trim().isEmpty ||
          request.companyAddress.trim().isEmpty ||
          request.representativeName.trim().isEmpty ||
          request.representativePhoneNumber.trim().isEmpty ||
          request.representativeJob.trim().isEmpty) {
        return 'Bạn phải nhập đầy đủ thông tin doanh nghiệp tự liên hệ.';
      }

      if (!_isValidPhoneNumber(request.representativePhoneNumber)) {
        return 'Số điện thoại người hướng dẫn phải có đúng 10 chữ số.';
      }

      if (request.expectedEndTime.isBefore(request.expectedStartTime)) {
        return 'Thời gian thực tập dự kiến không hợp lệ.';
      }
    }

    return null;
  }

  bool _isValidPhoneNumber(String value) {
    final normalized = value.trim();
    return RegExp(r'^\d{10}$').hasMatch(normalized);
  }

  void _onSubmitStateCleared(
    InternshipRegistrationSubmitStateCleared event,
    Emitter<InternshipRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        uploadStatus: InternshipCvUploadStatus.initial,
        submitStatus: InternshipRegistrationSubmitStatus.initial,
        uploadedCv: null,
        submittedRegistration: null,
        message: null,
      ),
    );
  }

  void _onUploadedCvCleared(
    InternshipUploadedCvCleared event,
    Emitter<InternshipRegistrationSubmitState> emit,
  ) {
    emit(
      state.copyWith(
        uploadStatus: InternshipCvUploadStatus.initial,
        uploadedCv: null,
      ),
    );
  }
}

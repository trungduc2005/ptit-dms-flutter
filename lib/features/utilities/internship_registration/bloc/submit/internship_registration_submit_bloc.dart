import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_model.dart';
import 'package:ptit_dms_flutter/data/models/intern_registration_request_model.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_cv_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/intern_registration_repository.dart';

import 'internship_registration_submit_event.dart';
import 'internship_registration_submit_state.dart';

export 'internship_registration_submit_event.dart';
export 'internship_registration_submit_state.dart';

class InternshipRegistrationSubmitBloc extends Bloc<
    InternshipRegistrationSubmitEvent, InternshipRegistrationSubmitState> {
  InternshipRegistrationSubmitBloc({
    required InternCvRepository internCvRepository,
    required InternRegistrationRepository internRegistrationRepository,
  })  : _internCvRepository = internCvRepository,
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
          message: 'Upload CV thanh cong.',
        ),
      );
    } on DioException catch (e) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: InternshipCvUploadStatus.failure,
          uploadedCv: null,
          message: _readErrorMessage(e, 'Upload CV that bai.'),
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          uploadStatus: InternshipCvUploadStatus.failure,
          uploadedCv: null,
          message: 'Upload CV that bai.',
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
      successMessage: 'Dang ky thuc tap thanh cong.',
      failureMessage: 'Dang ky thuc tap that bai.',
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
      successMessage: 'Cap nhat dang ky thuc tap thanh cong.',
      failureMessage: 'Cap nhat dang ky thuc tap that bai.',
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
          message: _readErrorMessage(e, failureMessage),
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
      return 'Thieu nam hoc dang ky.';
    }

    final cvFileKey = request.cvFileKey.trim();
    final cvFileName = request.cvFileName.trim();

    if (allowMissingCv) {
      final hasAnyCvValue = cvFileKey.isNotEmpty || cvFileName.isNotEmpty;
      final hasFullCvValue = cvFileKey.isNotEmpty && cvFileName.isNotEmpty;

      if (hasAnyCvValue && !hasFullCvValue) {
        return 'Thong tin CV khong hop le.';
      }
    } else {
      if (cvFileKey.isEmpty || cvFileName.isEmpty) {
        return 'Ban phai upload CV truoc khi gui dang ky.';
      }
    }

    if (request.cpa < 0 || request.cpa > 4) {
      return 'CPA phai nam trong khoang 0 - 4.';
    }

    if (request is RegisterWishInternRequestModel) {
      if (expectedPreferredCompanyCount <= 0) {
        return 'Chua co cau hinh so luong nguyen vong dang ky.';
      }

      if (request.preferredCompanies.length != expectedPreferredCompanyCount) {
        return 'Ban phai chon du $expectedPreferredCompanyCount doanh nghiep nguyen vong.';
      }

      final normalized = request.preferredCompanies
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);

      if (normalized.length != request.preferredCompanies.length) {
        return 'Danh sach doanh nghiep nguyen vong khong hop le.';
      }

      if (normalized.toSet().length != normalized.length) {
        return 'Cac nguyen vong doanh nghiep khong duoc trung nhau.';
      }
    }

    if (request is RegisterYourselfInternRequestModel) {
      if (request.companyName.trim().isEmpty ||
          request.companyField.trim().isEmpty ||
          request.companyAddress.trim().isEmpty ||
          request.representativeName.trim().isEmpty ||
          request.representativePhoneNumber.trim().isEmpty ||
          request.representativeJob.trim().isEmpty) {
        return 'Ban phai nhap day du thong tin doanh nghiep tu lien he.';
      }

      if (!_isValidPhoneNumber(request.representativePhoneNumber)) {
        return 'So dien thoai nguoi huong dan phai co dung 10 chu so.';
      }

      if (request.expectedEndTime.isBefore(request.expectedStartTime)) {
        return 'Thoi gian thuc tap du kien khong hop le.';
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

  String _readErrorMessage(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return error.message ?? fallback;
  }
}

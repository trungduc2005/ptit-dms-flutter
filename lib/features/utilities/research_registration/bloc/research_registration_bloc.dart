import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptit_dms_flutter/core/error/app_exception.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/research_registration_request.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';
import 'package:ptit_dms_flutter/domain/repositories/research_repository.dart';
import 'package:ptit_dms_flutter/domain/repositories/timeline_repository.dart';

import 'research_registration_event.dart';
import 'research_registration_state.dart';

export 'research_registration_event.dart';
export 'research_registration_state.dart';

class ResearchRegistrationBloc
    extends Bloc<ResearchRegistrationEvent, ResearchRegistrationState> {
  ResearchRegistrationBloc({
    required ResearchRepository repository,
    required TimelineRepository timelineRepository,
  }) : _repository = repository,
       _timelineRepository = timelineRepository,
       super(const ResearchRegistrationState()) {
    on<ResearchRegistrationStarted>(_onStarted);
    on<ResearchRegistrationRefreshed>(_onRefreshed);
    on<ResearchRegistrationCreated>(_onCreated);
    on<ResearchRegistrationUpdated>(_onUpdated);
    on<ResearchRegistrationActionStateCleared>(_onActionStateCleared);
  }

  static const _registrationTimelineType = 'researchRegistration';

  final ResearchRepository _repository;
  final TimelineRepository _timelineRepository;

  Future<void> _onStarted(
    ResearchRegistrationStarted event,
    Emitter<ResearchRegistrationState> emit,
  ) async {
    final yearId = event.yearId.trim();
    final type = event.type.trim();
    final validationMessage = _validateLoadParameters(
      yearId: yearId,
      type: type,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ResearchRegistrationLoadStatus.failure,
          yearId: yearId,
          type: type,
          researches: const [],
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(emit, yearId: yearId, type: type);
  }

  Future<void> _onRefreshed(
    ResearchRegistrationRefreshed event,
    Emitter<ResearchRegistrationState> emit,
  ) async {
    final validationMessage = _validateLoadParameters(
      yearId: state.yearId,
      type: state.type,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          loadStatus: ResearchRegistrationLoadStatus.failure,
          loadErrorMessage: validationMessage,
        ),
      );
      return;
    }

    await _load(emit, yearId: state.yearId, type: state.type);
  }

  Future<void> _load(
    Emitter<ResearchRegistrationState> emit, {
    required String yearId,
    required String type,
  }) async {
    emit(
      state.copyWith(
        loadStatus: ResearchRegistrationLoadStatus.loading,
        yearId: yearId,
        type: type,
        registrationTimeline: null,
        loadErrorMessage: null,
      ),
    );

    try {
      final results = await Future.wait<Object>([
        _repository.getUserResearches(yearId: yearId, type: type),
        _timelineRepository.getResearchTimelines(academicYearId: yearId),
      ]);
      final researches = results[0] as List<Research>;
      final timelines = results[1] as List<Timeline>;

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          loadStatus: ResearchRegistrationLoadStatus.success,
          researches: List<Research>.unmodifiable(researches),
          registrationTimeline: _findRegistrationTimeline(timelines),
          loadErrorMessage: null,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ResearchRegistrationLoadStatus.failure,
          loadErrorMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          loadStatus: ResearchRegistrationLoadStatus.failure,
          loadErrorMessage: 'Không thể tải danh sách nghiên cứu khoa học.',
        ),
      );
    }
  }

  Future<void> _onCreated(
    ResearchRegistrationCreated event,
    Emitter<ResearchRegistrationState> emit,
  ) async {
    await _save(
      emit,
      request: event.request,
      action: ResearchRegistrationAction.create,
      operation: () => _repository.createResearch(request: event.request),
      successMessage: 'Đăng ký nghiên cứu khoa học thành công.',
      failureMessage: 'Không thể đăng ký nghiên cứu khoa học.',
    );
  }

  Future<void> _onUpdated(
    ResearchRegistrationUpdated event,
    Emitter<ResearchRegistrationState> emit,
  ) async {
    final researchId = event.researchId.trim();
    if (researchId.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: ResearchRegistrationAction.update,
          savedResearch: null,
          actionMessage: 'Thiếu mã nghiên cứu khoa học.',
        ),
      );
      return;
    }

    final currentResearch = _findByResearchId(researchId);
    if (currentResearch != null && !currentResearch.isEditable) {
      emit(
        state.copyWith(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: ResearchRegistrationAction.update,
          savedResearch: null,
          actionMessage: 'Đề tài đã được duyệt nên không thể chỉnh sửa.',
        ),
      );
      return;
    }

    await _save(
      emit,
      request: event.request,
      action: ResearchRegistrationAction.update,
      operation: () => _repository.updateResearch(
        researchId: researchId,
        request: event.request,
      ),
      successMessage: 'Cập nhật nghiên cứu khoa học thành công.',
      failureMessage: 'Không thể cập nhật nghiên cứu khoa học.',
    );
  }

  Future<void> _save(
    Emitter<ResearchRegistrationState> emit, {
    required ResearchRegistrationRequest request,
    required ResearchRegistrationAction action,
    required Future<Research> Function() operation,
    required String successMessage,
    required String failureMessage,
  }) async {
    final validationMessage = _validateRequest(request);
    if (validationMessage != null) {
      emit(
        state.copyWith(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: action,
          savedResearch: null,
          actionMessage: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        actionStatus: ResearchRegistrationActionStatus.loading,
        action: action,
        savedResearch: null,
        actionMessage: null,
      ),
    );

    try {
      final research = await operation();

      if (emit.isDone || isClosed) return;

      emit(
        state.copyWith(
          actionStatus: ResearchRegistrationActionStatus.success,
          action: action,
          researches: _mergeResearch(state.researches, research),
          savedResearch: research,
          actionMessage: successMessage,
        ),
      );
    } on AppException catch (error) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: action,
          savedResearch: null,
          actionMessage: error.message,
        ),
      );
    } catch (_) {
      if (emit.isDone || isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ResearchRegistrationActionStatus.failure,
          action: action,
          savedResearch: null,
          actionMessage: failureMessage,
        ),
      );
    }
  }

  Timeline? _findRegistrationTimeline(List<Timeline> timelines) {
    for (final timeline in timelines) {
      if (timeline.type == _registrationTimelineType) return timeline;
    }

    // The research timeline endpoint is already scoped to the selected
    // academic year and student target. Some API responses use a legacy or
    // missing type, so keep the endpoint result as a safe fallback.
    return timelines.firstOrNull;
  }

  Research? _findByResearchId(String researchId) {
    for (final research in state.researches) {
      if (research.researchId == researchId) return research;
    }
    return null;
  }

  List<Research> _mergeResearch(
    List<Research> researches,
    Research savedResearch,
  ) {
    final index = researches.indexWhere(
      (item) =>
          item.id == savedResearch.id ||
          item.researchId == savedResearch.researchId,
    );
    if (index < 0) {
      return List<Research>.unmodifiable([savedResearch, ...researches]);
    }

    final updated = List<Research>.of(researches);
    updated[index] = savedResearch;
    return List<Research>.unmodifiable(updated);
  }

  String? _validateLoadParameters({
    required String yearId,
    required String type,
  }) {
    if (yearId.isEmpty) return 'Thiếu năm học.';
    if (type.isEmpty) return 'Thiếu loại nghiên cứu.';
    return null;
  }

  String? _validateRequest(ResearchRegistrationRequest request) {
    if (request.yearId.trim().isEmpty) return 'Thiếu năm học.';
    if (request.type.trim().isEmpty) return 'Thiếu loại nghiên cứu.';
    if (request.researchTopic.trim().isEmpty) {
      return 'Bạn phải nhập tên đề tài nghiên cứu.';
    }
    if (request.keyword.trim().isEmpty) {
      return 'Bạn phải nhập từ khóa nghiên cứu.';
    }
    if (request.outcome.trim().isEmpty) {
      return 'Bạn phải nhập sản phẩm dự kiến.';
    }
    if (request.description.trim().isEmpty) {
      return 'Bạn phải nhập mô tả nghiên cứu.';
    }
    if (request.researchNecessity.trim().isEmpty) {
      return 'Bạn phải nhập tính cấp thiết của nghiên cứu.';
    }
    if (request.nationalOverview.trim().isEmpty) {
      return 'Bạn phải nhập tổng quan nghiên cứu trong nước.';
    }
    if (request.internationalOverview.trim().isEmpty) {
      return 'Bạn phải nhập tổng quan nghiên cứu quốc tế.';
    }

    final memberIds = <String>{};
    for (final member in request.members) {
      final memberId = member.memberId.trim();
      if (memberId.isEmpty) return 'Thành viên nghiên cứu không hợp lệ.';
      if (!memberIds.add(memberId)) {
        return 'Danh sách thành viên nghiên cứu bị trùng.';
      }
    }
    return null;
  }

  void _onActionStateCleared(
    ResearchRegistrationActionStateCleared event,
    Emitter<ResearchRegistrationState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: ResearchRegistrationActionStatus.initial,
        action: null,
        savedResearch: null,
        actionMessage: null,
      ),
    );
  }
}

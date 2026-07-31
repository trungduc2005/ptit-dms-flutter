import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/domain/entities/research.dart';
import 'package:ptit_dms_flutter/domain/entities/timeline.dart';

enum ResearchRegistrationLoadStatus { initial, loading, success, failure }

enum ResearchRegistrationActionStatus { initial, loading, success, failure }

enum ResearchRegistrationAction { create, update }

const _unset = Object();

final class ResearchRegistrationState extends Equatable {
  const ResearchRegistrationState({
    this.loadStatus = ResearchRegistrationLoadStatus.initial,
    this.actionStatus = ResearchRegistrationActionStatus.initial,
    this.action,
    this.yearId = '',
    this.type = '',
    this.researches = const [],
    this.registrationTimeline,
    this.savedResearch,
    this.loadErrorMessage,
    this.actionMessage,
  });

  final ResearchRegistrationLoadStatus loadStatus;
  final ResearchRegistrationActionStatus actionStatus;
  final ResearchRegistrationAction? action;
  final String yearId;
  final String type;
  final List<Research> researches;
  final Timeline? registrationTimeline;
  final Research? savedResearch;
  final String? loadErrorMessage;
  final String? actionMessage;

  bool get isLoading => loadStatus == ResearchRegistrationLoadStatus.loading;

  bool get isSubmitting =>
      actionStatus == ResearchRegistrationActionStatus.loading;

  bool get isEmpty =>
      loadStatus == ResearchRegistrationLoadStatus.success &&
      researches.isEmpty;

  ResearchRegistrationState copyWith({
    ResearchRegistrationLoadStatus? loadStatus,
    ResearchRegistrationActionStatus? actionStatus,
    Object? action = _unset,
    String? yearId,
    String? type,
    List<Research>? researches,
    Object? registrationTimeline = _unset,
    Object? savedResearch = _unset,
    Object? loadErrorMessage = _unset,
    Object? actionMessage = _unset,
  }) {
    return ResearchRegistrationState(
      loadStatus: loadStatus ?? this.loadStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      action: identical(action, _unset)
          ? this.action
          : action as ResearchRegistrationAction?,
      yearId: yearId ?? this.yearId,
      type: type ?? this.type,
      researches: researches ?? this.researches,
      registrationTimeline: identical(registrationTimeline, _unset)
          ? this.registrationTimeline
          : registrationTimeline as Timeline?,
      savedResearch: identical(savedResearch, _unset)
          ? this.savedResearch
          : savedResearch as Research?,
      loadErrorMessage: identical(loadErrorMessage, _unset)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      actionMessage: identical(actionMessage, _unset)
          ? this.actionMessage
          : actionMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    actionStatus,
    action,
    yearId,
    type,
    researches,
    registrationTimeline,
    savedResearch,
    loadErrorMessage,
    actionMessage,
  ];
}

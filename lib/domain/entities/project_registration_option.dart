import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class ProjectPeriodOption extends Equatable {
  const ProjectPeriodOption({required this.name, this.id = ''});

  final String id;
  final String name;

  factory ProjectPeriodOption.fromJson(Map<String, dynamic> json) {
    return ProjectPeriodOption(
      id: asString(json['_id']) ?? asString(json['id']) ?? '',
      name: asString(json['name']) ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class ProjectGuiderOption extends Equatable {
  const ProjectGuiderOption({
    required this.lecturerId,
    required this.fullName,
    this.departmentName = '',
    this.limit = 0,
    this.usedSlot = 0,
  });

  final String lecturerId;
  final String fullName;
  final String departmentName;
  final int limit;
  final int usedSlot;

  int get remainingSlot => (limit - usedSlot).clamp(0, limit);
  bool get isFull => remainingSlot <= 0;

  factory ProjectGuiderOption.fromJson(Map<String, dynamic> json) {
    final userJson = json['userId'] is Map
        ? Map<String, dynamic>.from(json['userId'] as Map)
        : const <String, dynamic>{};
    final departmentJson = userJson['departmentId'] is Map
        ? Map<String, dynamic>.from(userJson['departmentId'] as Map)
        : const <String, dynamic>{};

    return ProjectGuiderOption(
      lecturerId:
          asString(json['lecturerId']) ??
          asString(json['_id']) ??
          asString(json['id']) ??
          '',
      fullName:
          asString(userJson['fullName']) ??
          asString(json['fullName']) ??
          asString(json['lecturerName']) ??
          '',
      departmentName:
          asString(departmentJson['name']) ??
          asString(json['departmentName']) ??
          '',
      limit: asInt(json['limit']) ?? 0,
      usedSlot: asInt(json['usedSlot']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    lecturerId,
    fullName,
    departmentName,
    limit,
    usedSlot,
  ];
}

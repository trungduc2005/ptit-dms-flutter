import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class TimelineAcademicYearRefModel extends Equatable {
  const TimelineAcademicYearRefModel({
    required this.id,
    this.code,
    this.name,
    this.startYear,
    this.endYear,
    this.isActive,
    this.isCurrent,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  final String id;
  final String? code;
  final String? name;
  final int? startYear;
  final int? endYear;
  final bool? isActive;
  final bool? isCurrent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  factory TimelineAcademicYearRefModel.fromJson(Map<String, dynamic> json) {
    return TimelineAcademicYearRefModel(
      id: asString(json['_id']) ?? '',
      code: asString(json['code']),
      name: asString(json['name']),
      startYear: asInt(json['startYear']),
      endYear: asInt(json['endYear']),
      isActive: asBool(json['isActive']),
      isCurrent: asBool(json['isCurrent']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      version: asInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'name': name,
      'startYear': startYear,
      'endYear': endYear,
      'isActive': isActive,
      'isCurrent': isCurrent,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        startYear,
        endYear,
        isActive,
        isCurrent,
        createdAt,
        updatedAt,
        version,
      ];
}

class TimelineModel extends Equatable {
  const TimelineModel({
    required this.id,
    required this.name,
    this.type,
    this.key,
    this.role,
    this.startTime,
    this.endTime,
    this.preferredCompanyCount,
    this.autoFilterProcessedAt,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.academicYearId,
    this.academicYear,
    this.academicYearRef,
  });

  final String id;
  final String name;
  final String? type;
  final String? key;
  final String? role;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? preferredCompanyCount;
  final DateTime? autoFilterProcessedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? academicYearId;
  final String? academicYear;
  final TimelineAcademicYearRefModel? academicYearRef;

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    final academicYearRefJson = json['academicYearRef'];

    return TimelineModel(
      id: asString(json['_id']) ?? '',
      name: asString(json['name']) ?? '',
      type: asString(json['type']),
      key: asString(json['key']),
      role: asString(json['role']),
      startTime: asDateTime(json['startTime']),
      endTime: asDateTime(json['endTime']),
      preferredCompanyCount: asInt(json['preferredCompanyCount']),
      autoFilterProcessedAt: asDateTime(json['autoFilterProcessedAt']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      version: asInt(json['__v']),
      academicYearId: asString(json['academicYearId']),
      academicYear: asString(json['academicYear']),
      academicYearRef: academicYearRefJson is Map
          ? TimelineAcademicYearRefModel.fromJson(
              Map<String, dynamic>.from(academicYearRefJson),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'key': key,
      'role': role,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'preferredCompanyCount': preferredCompanyCount,
      'autoFilterProcessedAt': autoFilterProcessedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
      'academicYearId': academicYearId,
      'academicYear': academicYear,
      'academicYearRef': academicYearRef?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        key,
        role,
        startTime,
        endTime,
        preferredCompanyCount,
        autoFilterProcessedAt,
        createdAt,
        updatedAt,
        version,
        academicYearId,
        academicYear,
        academicYearRef,
      ];
}

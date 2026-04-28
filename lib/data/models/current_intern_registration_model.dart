import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class CurrentInternRegistrationModel extends Equatable {
  const CurrentInternRegistrationModel({
    required this.id,
    required this.internId,
    required this.studentId,
    this.studentRef,
    required this.type,
    this.cohort,
    this.academicYearRef,
    this.companyId,
    this.companyName,
    this.companyField,
    this.companyAddress,
    this.representativeName,
    this.representativePhoneNumber,
    this.representativeJob,
    required this.preferredCompanies,
    this.cvFileName,
    this.cvFileKey,
    required this.rejectReasons,
    this.status,
    this.cpa,
    this.expectedStartTime,
    this.expectedEndTime,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.selfContactGroupId,
    this.representativeStudentId,
    this.selfContactGroupMembers = const [],
  });

  final String id;
  final String internId;
  final String studentId;
  final String? studentRef;
  final String type;
  final String? cohort;
  final CurrentInternAcademicYearRefModel? academicYearRef;
  final String? companyId;
  final String? companyName;
  final String? companyField;
  final String? companyAddress;
  final String? representativeName;
  final String? representativePhoneNumber;
  final String? representativeJob;
  final List<CurrentInternPreferredCompanyModel> preferredCompanies;
  final String? cvFileName;
  final String? cvFileKey;
  final List<CurrentInternRejectReasonModel> rejectReasons;
  final String? status;
  final double? cpa;
  final DateTime? expectedStartTime;
  final DateTime? expectedEndTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? selfContactGroupId;
  final String? representativeStudentId;
  final List<CurrentInternSelfContactGroupMemberModel> selfContactGroupMembers;

  factory CurrentInternRegistrationModel.fromJson(Map<String, dynamic> json) {
    final academicYearRefJson = json['academicYearRef'];
    final preferredCompaniesJson = json['preferredCompanies'];
    final selfContactGroupMembersJson = json['selfContactGroupMembers'];

    return CurrentInternRegistrationModel(
      id: asString(json['_id']) ?? '',
      internId: asString(json['internId']) ?? '',
      studentId: asString(json['studentId']) ?? '',
      studentRef: _asIdValue(json['studentRef']),
      type: asString(json['type']) ?? '',
      cohort: asString(json['cohort']),
      academicYearRef: academicYearRefJson is Map
          ? CurrentInternAcademicYearRefModel.fromJson(
              Map<String, dynamic>.from(academicYearRefJson),
            )
          : null,
      companyId: asString(json['companyId']),
      companyName: asString(json['companyName']),
      companyField: asString(json['companyField']),
      companyAddress: asString(json['companyAddress']),
      representativeName: asString(json['representativeName']),
      representativePhoneNumber: asString(json['representativePhoneNumber']),
      representativeJob: asString(json['representativeJob']),
      preferredCompanies: preferredCompaniesJson is List
          ? preferredCompaniesJson
                .whereType<Map>()
                .map(
                  (item) => CurrentInternPreferredCompanyModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
      cvFileName: asString(json['cvFileName']),
      cvFileKey: asString(json['cvFileKey']),
      rejectReasons: _asRejectReasonList(json['rejectReasons']),
      status: asString(json['status']),
      cpa: asDouble(json['cpa']),
      expectedStartTime: asDateTime(json['expectedStartTime']),
      expectedEndTime: asDateTime(json['expectedEndTime']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      version: asInt(json['__v']),
      selfContactGroupId: asString(json['selfContactGroupId']),
      representativeStudentId: asString(json['representativeStudentId']),
      selfContactGroupMembers: selfContactGroupMembersJson is List
          ? selfContactGroupMembersJson
                .whereType<Map>()
                .map(
                  (item) => CurrentInternSelfContactGroupMemberModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'internId': internId,
      'studentId': studentId,
      'studentRef': studentRef,
      'type': type,
      'cohort': cohort,
      'academicYearRef': academicYearRef?.toJson(),
      'companyId': companyId,
      'companyName': companyName,
      'companyField': companyField,
      'companyAddress': companyAddress,
      'representativeName': representativeName,
      'representativePhoneNumber': representativePhoneNumber,
      'representativeJob': representativeJob,
      'preferredCompanies': preferredCompanies
          .map((item) => item.toJson())
          .toList(growable: false),
      'cvFileName': cvFileName,
      'cvFileKey': cvFileKey,
      'rejectReasons': rejectReasons
          .map((item) => item.toJson())
          .toList(growable: false),
      'status': status,
      'cpa': cpa,
      'expectedStartTime': expectedStartTime?.toIso8601String(),
      'expectedEndTime': expectedEndTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
      'selfContactGroupId': selfContactGroupId,
      'representativeStudentId': representativeStudentId,
      'selfContactGroupMembers': selfContactGroupMembers
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }

  static String? _asIdValue(Object? value) {
    if (value is Map) {
      return asString(value['_id']) ?? asString(value['id']);
    }

    return asString(value);
  }

  static List<CurrentInternRejectReasonModel> _asRejectReasonList(
    Object? value,
  ) {
    if (value is! List) {
      return const [];
    }

    final results = <CurrentInternRejectReasonModel>[];

    for (final item in value) {
      if (item is Map) {
        results.add(
          CurrentInternRejectReasonModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
        continue;
      }

      final text = item?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        results.add(CurrentInternRejectReasonModel(reason: text));
      }
    }

    return List.unmodifiable(results);
  }

  @override
  List<Object?> get props => [
    id,
    internId,
    studentId,
    studentRef,
    type,
    cohort,
    academicYearRef,
    companyId,
    companyName,
    companyField,
    companyAddress,
    representativeName,
    representativePhoneNumber,
    representativeJob,
    preferredCompanies,
    cvFileName,
    cvFileKey,
    rejectReasons,
    status,
    cpa,
    expectedStartTime,
    expectedEndTime,
    createdAt,
    updatedAt,
    version,
    selfContactGroupId,
    representativeStudentId,
    selfContactGroupMembers,
  ];
}

class CurrentInternAcademicYearRefModel extends Equatable {
  const CurrentInternAcademicYearRefModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory CurrentInternAcademicYearRefModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CurrentInternAcademicYearRefModel(
      id: asString(json['_id']) ?? '',
      name: asString(json['name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name];
}

class CurrentInternPreferredCompanyModel extends Equatable {
  const CurrentInternPreferredCompanyModel({
    this.order,
    this.companyId,
    this.companyName,
  });

  final int? order;
  final String? companyId;
  final String? companyName;

  factory CurrentInternPreferredCompanyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CurrentInternPreferredCompanyModel(
      order: asInt(json['order']),
      companyId: asString(json['companyId']),
      companyName: asString(json['companyName']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'order': order, 'companyId': companyId, 'companyName': companyName};
  }

  @override
  List<Object?> get props => [order, companyId, companyName];
}

class CurrentInternRejectReasonModel extends Equatable {
  const CurrentInternRejectReasonModel({
    required this.reason,
    this.rejectedAt,
    this.rejectedBy,
  });

  final String reason;
  final DateTime? rejectedAt;
  final String? rejectedBy;

  factory CurrentInternRejectReasonModel.fromJson(Map<String, dynamic> json) {
    return CurrentInternRejectReasonModel(
      reason: asString(json['reason']) ?? '',
      rejectedAt: asDateTime(json['rejectedAt']),
      rejectedBy: asString(json['rejectedBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectedBy': rejectedBy,
    };
  }

  @override
  List<Object?> get props => [reason, rejectedAt, rejectedBy];
}

class CurrentInternSelfContactGroupMemberModel extends Equatable {
  const CurrentInternSelfContactGroupMemberModel({
    required this.studentId,
    required this.studentName,
    this.cpa,
    this.cvFileName,
    this.cvFileKey,
    this.isRepresentative = false,
  });

  final String studentId;
  final String studentName;
  final double? cpa;
  final String? cvFileName;
  final String? cvFileKey;
  final bool isRepresentative;

  factory CurrentInternSelfContactGroupMemberModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CurrentInternSelfContactGroupMemberModel(
      studentId: asString(json['studentId']) ?? '',
      studentName: asString(json['studentName']) ?? '',
      cpa: asDouble(json['cpa']),
      cvFileName: asString(json['cvFileName']),
      cvFileKey: asString(json['cvFileKey']),
      isRepresentative: asBool(json['isRepresentative']) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'cpa': cpa,
      'cvFileName': cvFileName,
      'cvFileKey': cvFileKey,
      'isRepresentative': isRepresentative,
    };
  }

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    cpa,
    cvFileName,
    cvFileKey,
    isRepresentative,
  ];
}

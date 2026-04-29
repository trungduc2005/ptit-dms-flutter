import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class InternRegistration extends Equatable {
  const InternRegistration({
    required this.id,
    required this.internId,
    required this.studentId,
    this.studentRef,
    required this.type,
    this.cvFile,
    this.companyInfo,
    required this.preferredCompanies,
    this.cohort,
    this.academicYearRef,
    this.status,
    this.cpa,
    this.expectedStartTime,
    this.expectedEndTime,
    required this.rejectReasons,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  final String id;
  final String internId;
  final String studentId;
  final String? studentRef;
  final String type;
  final InternRegistrationCvFile? cvFile;
  final InternRegistrationCompanyInfo? companyInfo;
  final List<InternRegistrationPreferredCompany> preferredCompanies;
  final String? cohort;
  final String? academicYearRef;
  final String? status;
  final double? cpa;
  final DateTime? expectedStartTime;
  final DateTime? expectedEndTime;
  final List<InternRegistrationRejectReason> rejectReasons;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  factory InternRegistration.fromJson(Map<String, dynamic> json) {
    final cvFileJson = json['cvFile'];
    final companyInfoJson = json['companyInfo'];
    final preferredCompaniesJson = json['preferredCompanies'];

    return InternRegistration(
      id: asString(json['_id']) ?? '',
      internId: asString(json['internId']) ?? '',
      studentId: asString(json['studentId']) ?? '',
      studentRef: _asIdValue(json['studentRef']),
      type: asString(json['type']) ?? '',
      cvFile: cvFileJson is Map
          ? InternRegistrationCvFile.fromJson(
              Map<String, dynamic>.from(cvFileJson),
            )
          : null,
      companyInfo: companyInfoJson is Map
          ? InternRegistrationCompanyInfo.fromJson(
              Map<String, dynamic>.from(companyInfoJson),
            )
          : null,
      preferredCompanies: preferredCompaniesJson is List
          ? preferredCompaniesJson
                .whereType<Map>()
                .map(
                  (item) => InternRegistrationPreferredCompany.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
      cohort: asString(json['cohort']),
      academicYearRef: _asIdValue(json['academicYearRef']),
      status: asString(json['status']),
      cpa: asDouble(json['cpa']),
      expectedStartTime: asDateTime(json['expectedStartTime']),
      expectedEndTime: asDateTime(json['expectedEndTime']),
      rejectReasons: _asRejectReasonList(json['rejectReasons']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      version: asInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'internId': internId,
      'studentId': studentId,
      'studentRef': studentRef,
      'type': type,
      'cvFile': cvFile?.toJson(),
      'companyInfo': companyInfo?.toJson(),
      'preferredCompanies': preferredCompanies
          .map((item) => item.toJson())
          .toList(growable: false),
      'cohort': cohort,
      'academicYearRef': academicYearRef,
      'status': status,
      'cpa': cpa,
      'expectedStartTime': expectedStartTime?.toIso8601String(),
      'expectedEndTime': expectedEndTime?.toIso8601String(),
      'rejectReasons': rejectReasons
          .map((item) => item.toJson())
          .toList(growable: false),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  static String? _asIdValue(Object? value) {
    if (value is Map) {
      return asString(value['_id']) ?? asString(value['id']);
    }

    return asString(value);
  }

  static List<InternRegistrationRejectReason> _asRejectReasonList(
    Object? value,
  ) {
    if (value is! List) {
      return const [];
    }

    final results = <InternRegistrationRejectReason>[];

    for (final item in value) {
      if (item is Map) {
        results.add(
          InternRegistrationRejectReason.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
        continue;
      }

      final text = item?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        results.add(InternRegistrationRejectReason(reason: text));
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
    cvFile,
    companyInfo,
    preferredCompanies,
    cohort,
    academicYearRef,
    status,
    cpa,
    expectedStartTime,
    expectedEndTime,
    rejectReasons,
    createdAt,
    updatedAt,
    version,
  ];
}

class InternRegistrationCvFile extends Equatable {
  const InternRegistrationCvFile({
    required this.fileName,
    required this.fileKey,
    this.fileType,
    this.uploadedAt,
  });

  final String fileName;
  final String fileKey;
  final String? fileType;
  final DateTime? uploadedAt;

  factory InternRegistrationCvFile.fromJson(Map<String, dynamic> json) {
    return InternRegistrationCvFile(
      fileName: asString(json['fileName']) ?? '',
      fileKey: asString(json['fileKey']) ?? '',
      fileType: asString(json['fileType']),
      uploadedAt: asDateTime(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileKey': fileKey,
      'fileType': fileType,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [fileName, fileKey, fileType, uploadedAt];
}

class InternRegistrationCompanyInfo extends Equatable {
  const InternRegistrationCompanyInfo({
    required this.companyName,
    this.companyField,
    this.companyAddress,
    this.representativeName,
    this.representativePhoneNumber,
    this.representativeJob,
  });

  final String companyName;
  final String? companyField;
  final String? companyAddress;
  final String? representativeName;
  final String? representativePhoneNumber;
  final String? representativeJob;

  factory InternRegistrationCompanyInfo.fromJson(Map<String, dynamic> json) {
    return InternRegistrationCompanyInfo(
      companyName: asString(json['companyName']) ?? '',
      companyField: asString(json['companyField']),
      companyAddress: asString(json['companyAddress']),
      representativeName: asString(json['representativeName']),
      representativePhoneNumber: asString(json['representativePhoneNumber']),
      representativeJob: asString(json['representativeJob']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'companyField': companyField,
      'companyAddress': companyAddress,
      'representativeName': representativeName,
      'representativePhoneNumber': representativePhoneNumber,
      'representativeJob': representativeJob,
    };
  }

  @override
  List<Object?> get props => [
    companyName,
    companyField,
    companyAddress,
    representativeName,
    representativePhoneNumber,
    representativeJob,
  ];
}

class InternRegistrationPreferredCompany extends Equatable {
  const InternRegistrationPreferredCompany({
    required this.id,
    this.order,
    this.companyRef,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int? order;
  final String? companyRef;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory InternRegistrationPreferredCompany.fromJson(
    Map<String, dynamic> json,
  ) {
    return InternRegistrationPreferredCompany(
      id: asString(json['_id']) ?? '',
      order: asInt(json['order']),
      companyRef: InternRegistration._asIdValue(json['companyRef']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order': order,
      'companyRef': companyRef,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, order, companyRef, createdAt, updatedAt];
}

class InternRegistrationRejectReason extends Equatable {
  const InternRegistrationRejectReason({
    required this.reason,
    this.rejectedAt,
    this.rejectedBy,
  });

  final String reason;
  final DateTime? rejectedAt;
  final String? rejectedBy;

  factory InternRegistrationRejectReason.fromJson(Map<String, dynamic> json) {
    return InternRegistrationRejectReason(
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

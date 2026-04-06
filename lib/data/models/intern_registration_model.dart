import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class InternRegistrationModel extends Equatable {
  const InternRegistrationModel({
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
  final InternRegistrationCvFileModel? cvFile;
  final InternRegistrationCompanyInfoModel? companyInfo;
  final List<InternRegistrationPreferredCompanyModel> preferredCompanies;
  final String? cohort;
  final String? academicYearRef;
  final String? status;
  final double? cpa;
  final DateTime? expectedStartTime;
  final DateTime? expectedEndTime;
  final List<String> rejectReasons;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  factory InternRegistrationModel.fromJson(Map<String, dynamic> json) {
    final cvFileJson = json['cvFile'];
    final companyInfoJson = json['companyInfo'];
    final preferredCompaniesJson = json['preferredCompanies'];

    return InternRegistrationModel(
      id: asString(json['_id']) ?? '',
      internId: asString(json['internId']) ?? '',
      studentId: asString(json['studentId']) ?? '',
      studentRef: asString(json['studentRef']),
      type: asString(json['type']) ?? '',
      cvFile: cvFileJson is Map
          ? InternRegistrationCvFileModel.fromJson(
              Map<String, dynamic>.from(cvFileJson),
            )
          : null,
      companyInfo: companyInfoJson is Map
          ? InternRegistrationCompanyInfoModel.fromJson(
              Map<String, dynamic>.from(companyInfoJson),
            )
          : null,
      preferredCompanies: preferredCompaniesJson is List
          ? preferredCompaniesJson
              .whereType<Map>()
              .map(
                (item) => InternRegistrationPreferredCompanyModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const [],
      cohort: asString(json['cohort']),
      academicYearRef: asString(json['academicYearRef']),
      status: asString(json['status']),
      cpa: asDouble(json['cpa']),
      expectedStartTime: asDateTime(json['expectedStartTime']),
      expectedEndTime: asDateTime(json['expectedEndTime']),
      rejectReasons: _asStringList(json['rejectReasons']),
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
      'rejectReasons': rejectReasons,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  static List<String> _asStringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
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

class InternRegistrationCvFileModel extends Equatable {
  const InternRegistrationCvFileModel({
    required this.fileName,
    required this.fileKey,
    this.fileType,
    this.uploadedAt,
  });

  final String fileName;
  final String fileKey;
  final String? fileType;
  final DateTime? uploadedAt;

  factory InternRegistrationCvFileModel.fromJson(Map<String, dynamic> json) {
    return InternRegistrationCvFileModel(
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

class InternRegistrationCompanyInfoModel extends Equatable {
  const InternRegistrationCompanyInfoModel({
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

  factory InternRegistrationCompanyInfoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InternRegistrationCompanyInfoModel(
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

class InternRegistrationPreferredCompanyModel extends Equatable {
  const InternRegistrationPreferredCompanyModel({
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

  factory InternRegistrationPreferredCompanyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InternRegistrationPreferredCompanyModel(
      id: asString(json['_id']) ?? '',
      order: asInt(json['order']),
      companyRef: asString(json['companyRef']),
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

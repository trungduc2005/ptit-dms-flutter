import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class Company extends Equatable {
  const Company({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyField,
    this.companyAddress,
    this.representativeName,
    this.representativePhoneNumber,
    this.representativeJob,
    this.contactLink,
    this.jobDescription,
    this.benefits,
    this.qualityRequirements,
    this.internshipLocation,
    this.studentLimit,
    this.allowOverLimit,
    this.minCpa,
    this.academicYearRef,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String? companyField;
  final String? companyAddress;
  final String? representativeName;
  final String? representativePhoneNumber;
  final String? representativeJob;
  final String? contactLink;
  final String? jobDescription;
  final String? benefits;
  final String? qualityRequirements;
  final String? internshipLocation;
  final int? studentLimit;
  final bool? allowOverLimit;
  final double? minCpa;
  final String? academicYearRef;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      companyField: asString(json['companyField']),
      companyAddress: asString(json['companyAddress']),
      representativeName: asString(json['representativeName']),
      representativePhoneNumber: asString(json['representativePhoneNumber']),
      representativeJob: asString(json['representativeJob']),
      contactLink: asString(json['contactLink']),
      jobDescription: asString(json['jobDescription']),
      benefits: asString(json['benefits']),
      qualityRequirements: asString(json['qualityRequirements']),
      internshipLocation: asString(json['internshipLocation']),
      studentLimit: asInt(json['studentLimit']),
      allowOverLimit: asBool(json['allowOverLimit']),
      minCpa: asDouble(json['minCpa']),
      academicYearRef: asString(json['academicYearRef']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      version: asInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'companyId': companyId,
      'companyName': companyName,
      'companyField': companyField,
      'companyAddress': companyAddress,
      'representativeName': representativeName,
      'representativePhoneNumber': representativePhoneNumber,
      'representativeJob': representativeJob,
      'contactLink': contactLink,
      'jobDescription': jobDescription,
      'benefits': benefits,
      'qualityRequirements': qualityRequirements,
      'internshipLocation': internshipLocation,
      'studentLimit': studentLimit,
      'allowOverLimit': allowOverLimit,
      'minCpa': minCpa,
      'academicYearRef': academicYearRef,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    companyName,
    companyField,
    companyAddress,
    representativeName,
    representativePhoneNumber,
    representativeJob,
    contactLink,
    jobDescription,
    benefits,
    qualityRequirements,
    internshipLocation,
    studentLimit,
    allowOverLimit,
    minCpa,
    academicYearRef,
    createdAt,
    updatedAt,
    version,
  ];
}

import 'package:equatable/equatable.dart';

enum InternRegistrationType {
  registerWish('registerWish'),
  yourself('yourself'),
  facultyAssign('facultyAssign');

  const InternRegistrationType(this.value);

  final String value;
}

abstract class InternRegistrationRequest extends Equatable {
  const InternRegistrationRequest({
    required this.type,
    required this.academicYearId,
    required this.cpa,
    required this.cvFileKey,
    required this.cvFileName,
  });

  final InternRegistrationType type;
  final String academicYearId;
  final double cpa;
  final String cvFileKey;
  final String cvFileName;

  Map<String, dynamic> toJson();

  Map<String, dynamic> commonToJson() {
    return {
      'type': type.value,
      'academicYearId': academicYearId,
      'cpa': cpa,
      'cvFileKey': cvFileKey,
      'cvFileName': cvFileName,
    };
  }

  @override
  List<Object?> get props => [type, academicYearId, cpa, cvFileKey, cvFileName];
}

class RegisterWishInternRequest extends InternRegistrationRequest {
  const RegisterWishInternRequest({
    required super.academicYearId,
    required super.cpa,
    required super.cvFileKey,
    required super.cvFileName,
    required this.preferredCompanies,
  }) : super(type: InternRegistrationType.registerWish);

  final List<String> preferredCompanies;

  @override
  Map<String, dynamic> toJson() {
    return {...commonToJson(), 'preferredCompanies': preferredCompanies};
  }

  @override
  List<Object?> get props => [...super.props, preferredCompanies];
}

class RegisterYourselfInternRequest extends InternRegistrationRequest {
  const RegisterYourselfInternRequest({
    required super.academicYearId,
    required super.cpa,
    required super.cvFileKey,
    required super.cvFileName,
    required this.companyName,
    required this.companyField,
    required this.companyAddress,
    required this.representativeName,
    required this.representativePhoneNumber,
    required this.representativeJob,
    required this.expectedStartTime,
    required this.expectedEndTime,
    required this.selfContactGroupMembers,
  }) : super(type: InternRegistrationType.yourself);

  final String companyName;
  final String companyField;
  final String companyAddress;
  final String representativeName;
  final String representativePhoneNumber;
  final String representativeJob;
  final DateTime expectedStartTime;
  final DateTime expectedEndTime;
  final List<SelfContactGroupMemberRequest> selfContactGroupMembers;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...commonToJson(),
      'companyName': companyName,
      'companyField': companyField,
      'companyAddress': companyAddress,
      'representativeName': representativeName,
      'representativePhoneNumber': representativePhoneNumber,
      'representativeJob': representativeJob,
      'expectedStartTime': expectedStartTime.toUtc().toIso8601String(),
      'expectedEndTime': expectedEndTime.toUtc().toIso8601String(),
      'selfContactGroupMembers': selfContactGroupMembers
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [
    ...super.props,
    companyName,
    companyField,
    companyAddress,
    representativeName,
    representativePhoneNumber,
    representativeJob,
    expectedStartTime,
    expectedEndTime,
    selfContactGroupMembers,
  ];
}

class SelfContactGroupMemberRequest extends Equatable {
  const SelfContactGroupMemberRequest({
    required this.studentId,
    required this.cpa,
    required this.cvFileKey,
    required this.cvFileName,
  });

  final String studentId;
  final double cpa;
  final String cvFileKey;
  final String cvFileName;

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'cpa': cpa,
      'cvFileKey': cvFileKey,
      'cvFileName': cvFileName,
    };
  }

  @override
  List<Object?> get props => [studentId, cpa, cvFileKey, cvFileName];
}

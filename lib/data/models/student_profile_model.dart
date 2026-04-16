import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class StudentProfileModel extends Equatable {
  const StudentProfileModel({
    required this.id,
    required this.studentId,
    required this.cohort,
    required this.major,
    this.subSpecialization,
    this.classInfo,
    this.user,
  });

  final String id;
  final String studentId;
  final String cohort;
  final List<String> major;
  final String? subSpecialization;
  final StudentProfileClassModel? classInfo;
  final StudentProfileUserModel? user;

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    final classJson = json['classId'];
    final userJson = json['userId'];
    final majorJson = json['major'];

    return StudentProfileModel(
      id: asString(json['_id']) ?? '',
      studentId: asString(json['studentId']) ?? '',
      cohort: asString(json['cohort']) ?? '',
      major: majorJson is List
          ? majorJson.map((item) => item.toString()).toList(growable: false)
          : const [],
      subSpecialization: asString(json['subSpecialization']),
      classInfo: classJson is Map
          ? StudentProfileClassModel.fromJson(
              Map<String, dynamic>.from(classJson),
            )
          : null,
      user: userJson is Map
          ? StudentProfileUserModel.fromJson(
              Map<String, dynamic>.from(userJson),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId,
      'cohort': cohort,
      'major': major,
      'subSpecialization': subSpecialization,
      'classId': classInfo?.toJson(),
      'userId': user?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    cohort,
    major,
    subSpecialization,
    classInfo,
    user,
  ];
}

class StudentProfileClassModel extends Equatable {
  const StudentProfileClassModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory StudentProfileClassModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileClassModel(
      id: asString(json['_id']) ?? '',
      name: asString(json['name']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

class StudentProfileUserModel extends Equatable {
  const StudentProfileUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.address,
    this.citizenId,
    this.roleName,
    this.facultyName,
    this.departmentName,
  });

  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  final String? address;
  final String? citizenId;
  final String? roleName;
  final String? facultyName;
  final String? departmentName;

  factory StudentProfileUserModel.fromJson(Map<String, dynamic> json) {
    final roleJson = json['roleId'];
    final facultyJson = json['facultyId'];
    final departmentJson = json['departmentId'];

    return StudentProfileUserModel(
      id: asString(json['_id']) ?? '',
      fullName: asString(json['fullName']) ?? '',
      username: asString(json['username']) ?? '',
      avatarUrl: asString(json['avatarUrl']),
      gender: asString(json['gender']),
      dateOfBirth: asDateTime(json['dateOfBirth']),
      phone: asString(json['phone']),
      email: asString(json['email']),
      address: asString(json['address']),
      citizenId: asString(json['citizenId']),
      roleName: roleJson is Map
          ? asString(roleJson['name'])
          : asString(roleJson),
      facultyName: facultyJson is Map
          ? asString(facultyJson['name'])
          : asString(facultyJson),
      departmentName: departmentJson is Map
          ? asString(departmentJson['name'])
          : asString(departmentJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phone': phone,
      'email': email,
      'address': address,
      'citizenId': citizenId,
      'roleId': roleName,
      'facultyId': facultyName,
      'departmentId': departmentName,
    };
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    username,
    avatarUrl,
    gender,
    dateOfBirth,
    phone,
    email,
    address,
    citizenId,
    roleName,
    facultyName,
    departmentName,
  ];
}

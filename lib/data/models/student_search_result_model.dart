import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class StudentSearchResultModel extends Equatable {
  const StudentSearchResultModel({
    required this.studentId,
    required this.label,
    required this.studentName,
  });

  final String studentId;
  final String label;
  final String studentName;

  factory StudentSearchResultModel.fromJson(Map<String, dynamic> json) {
    return StudentSearchResultModel(
      studentId: asString(json['studentId']) ?? '',
      label: asString(json['label']) ?? '',
      studentName: asString(json['studentName']) ?? '',
    );
  }

  @override
  List<Object?> get props => [studentId, label, studentName];
}

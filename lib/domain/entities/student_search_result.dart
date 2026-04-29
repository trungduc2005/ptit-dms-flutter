import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class StudentSearchResult extends Equatable {
  const StudentSearchResult({
    required this.studentId,
    required this.label,
    required this.studentName,
  });

  final String studentId;
  final String label;
  final String studentName;

  factory StudentSearchResult.fromJson(Map<String, dynamic> json) {
    return StudentSearchResult(
      studentId: asString(json['studentId']) ?? '',
      label: asString(json['label']) ?? '',
      studentName: asString(json['studentName']) ?? '',
    );
  }

  @override
  List<Object?> get props => [studentId, label, studentName];
}

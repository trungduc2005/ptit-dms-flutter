import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class ResearchMemberOption extends Equatable {
  const ResearchMemberOption({
    required this.id,
    required this.name,
    required this.label,
  });

  final String id;
  final String name;
  final String label;

  factory ResearchMemberOption.fromStudentJson(Map<String, dynamic> json) {
    final id = asString(json['studentId']) ?? '';
    final name = asString(json['studentName']) ?? '';
    return ResearchMemberOption(
      id: id,
      name: name,
      label: asString(json['label']) ?? '$id - $name',
    );
  }

  factory ResearchMemberOption.fromLecturerJson(Map<String, dynamic> json) {
    final id = asString(json['lecturerId']) ?? '';
    final name = asString(json['lecturerName']) ?? '';
    return ResearchMemberOption(
      id: id,
      name: name,
      label: asString(json['label']) ?? '$id - $name',
    );
  }

  @override
  List<Object?> get props => [id, name, label];
}

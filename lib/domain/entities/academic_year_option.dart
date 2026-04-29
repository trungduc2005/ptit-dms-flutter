import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class AcademicYearOption extends Equatable {
  const AcademicYearOption({required this.id, required this.name});

  final String id;
  final String name;

  factory AcademicYearOption.fromJson(Map<String, dynamic> json) {
    return AcademicYearOption(
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

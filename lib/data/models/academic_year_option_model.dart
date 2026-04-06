import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class AcademicYearOptionModel extends Equatable {
  AcademicYearOptionModel({required this.id, required this.name});

  final String id;
  final String name;

  factory AcademicYearOptionModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearOptionModel(
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

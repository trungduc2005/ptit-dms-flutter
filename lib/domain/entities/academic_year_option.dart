import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class AcademicYearOption extends Equatable {
  const AcademicYearOption({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;

  factory AcademicYearOption.fromJson(Map<String, dynamic> json) {
    final name = asString(json['name']) ?? '';
    final providedCode = asString(json['code'])?.trim() ?? '';

    return AcademicYearOption(
      id: asString(json['_id']) ?? '',
      code: providedCode.isNotEmpty ? providedCode : _extractCodeFromName(name),
      name: name,
    );
  }

  static String _extractCodeFromName(String name) {
    final years = RegExp(
      r'\d{4}',
    ).allMatches(name).map((match) => match.group(0));

    if (years.length < 2) return '';

    return '${years.elementAt(0)}-${years.elementAt(1)}';
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'code': code, 'name': name};
  }

  @override
  List<Object?> get props => [id, code, name];
}

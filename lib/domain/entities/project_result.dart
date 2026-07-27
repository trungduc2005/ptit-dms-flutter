class ProjectCloResult {
  const ProjectCloResult({
    required this.cloId,
    required this.cloName,
    required this.cloDescription,
    required this.cloWeight,
    required this.average,
  });

  final String cloId;
  final String cloName;
  final String cloDescription;
  final double cloWeight;
  final double average;

  factory ProjectCloResult.fromJson(Map<String, dynamic> json) {
    return ProjectCloResult(
      cloId: _readString(json, 'cloId'),
      cloName: _readString(json, 'cloName'),
      cloDescription: _readString(json, 'cloDescription'),
      cloWeight: _readDouble(json, 'cloWeight'),
      average: _readDouble(json, 'average'),
    );
  }
}

class ProjectResultMember {
  const ProjectResultMember({
    required this.studentId,
    required this.fullName,
    required this.clos,
    required this.totalGpa,
    this.id,
    this.avatarUrl,
    this.className,
    this.projectId,
    this.projectName,
  });

  final String? id;
  final String studentId;
  final String fullName;
  final String? avatarUrl;
  final String? className;
  final String? projectId;
  final String? projectName;
  final List<ProjectCloResult> clos;
  final double totalGpa;

  factory ProjectResultMember.fromJson(Map<String, dynamic> json) {
    final user = _readNullableObject(json['userId']);
    final studentClass = _readNullableObject(json['classId']);
    final rawClos = json['clos'];

    if (rawClos is! List) {
      throw const FormatException(
        'Danh sách kết quả chuẩn đầu ra không đúng định dạng.',
      );
    }

    return ProjectResultMember(
      id: _readNullableString(json, '_id'),
      studentId: _readString(json, 'studentId'),
      fullName:
          _readNullableString(user, 'fullName') ??
          _readNullableString(json, 'fullName') ??
          '',
      avatarUrl:
          _readNullableString(user, 'avatarUrl') ??
          _readNullableString(json, 'avatarUrl'),
      className:
          _readNullableString(studentClass, 'name') ??
          _readNullableString(json, 'className'),
      projectId: _readNullableString(json, 'projectId'),
      projectName: _readNullableString(json, 'projectName'),
      clos: rawClos
          .map(
            (item) => ProjectCloResult.fromJson(
              _asJsonObject(item, 'Kết quả chuẩn đầu ra'),
            ),
          )
          .toList(growable: false),
      totalGpa: _readDouble(json, 'totalGPA'),
    );
  }
}

class ProjectResult {
  const ProjectResult({
    required this.projectId,
    required this.projectName,
    required this.members,
  });

  final String projectId;
  final String projectName;
  final List<ProjectResultMember> members;

  bool get isPublished => members.isNotEmpty;

  factory ProjectResult.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    if (rawMembers is! List) {
      throw const FormatException(
        'Danh sách kết quả thành viên đồ án không đúng định dạng.',
      );
    }

    return ProjectResult(
      projectId: _readString(json, 'projectId'),
      projectName: _readString(json, 'projectName'),
      members: rawMembers
          .map(
            (item) => ProjectResultMember.fromJson(
              _asJsonObject(item, 'Kết quả thành viên đồ án'),
            ),
          )
          .toList(growable: false),
    );
  }
}

Map<String, dynamic> _asJsonObject(Object? value, String label) {
  if (value is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }
  return Map<String, dynamic>.from(value);
}

Map<String, dynamic> _readNullableObject(Object? value) {
  if (value is! Map) {
    return const <String, dynamic>{};
  }
  return Map<String, dynamic>.from(value);
}

String _readString(Map<String, dynamic> json, String key) {
  return _readNullableString(json, key) ?? '';
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  final text = value is String ? value : value.toString();
  return text.isEmpty ? null : text;
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

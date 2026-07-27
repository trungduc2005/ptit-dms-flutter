class ProjectCommitteeMember {
  const ProjectCommitteeMember({
    required this.memberId,
    required this.memberName,
    required this.department,
    required this.role,
    this.avatarUrl,
  });

  final String memberId;
  final String memberName;
  final String department;
  final String role;
  final String? avatarUrl;

  factory ProjectCommitteeMember.fromJson(Map<String, dynamic> json) {
    return ProjectCommitteeMember(
      memberId: _readString(json, 'memberId'),
      memberName: _readString(json, 'memberName'),
      department: _readString(json, 'department'),
      role: _readString(json, 'role'),
      avatarUrl: _readNullableString(json, 'avatarUrl'),
    );
  }
}

class ProjectCommitteeStudent {
  const ProjectCommitteeStudent({
    required this.studentRef,
    required this.studentId,
    required this.studentName,
    required this.role,
    this.classId,
    this.cohort,
    this.avatarUrl,
  });

  final String studentRef;
  final String studentId;
  final String studentName;
  final String role;
  final String? classId;
  final String? cohort;
  final String? avatarUrl;

  factory ProjectCommitteeStudent.fromJson(Map<String, dynamic> json) {
    return ProjectCommitteeStudent(
      studentRef: _readString(json, 'studentRef'),
      studentId: _readString(json, 'studentId'),
      studentName: _readString(json, 'studentName'),
      role: _readString(json, 'role'),
      classId: _readNullableString(json, 'classId'),
      cohort: _readNullableString(json, 'cohort'),
      avatarUrl:
          _readNullableString(json, 'avatarUrl') ??
          _readNullableString(json, 'avatar'),
    );
  }
}

class ProjectCommitteeProject {
  const ProjectCommitteeProject({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.members,
    required this.presentationOrder,
    this.guiderName,
    this.guiderId,
    this.reviewerName,
    this.reviewerId,
  });

  final String id;
  final String projectId;
  final String projectName;
  final List<ProjectCommitteeStudent> members;
  final String? guiderName;
  final String? guiderId;
  final String? reviewerName;
  final String? reviewerId;
  final int presentationOrder;

  factory ProjectCommitteeProject.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    if (rawMembers is! List) {
      throw const FormatException(
        'Danh sách sinh viên của đồ án không đúng định dạng.',
      );
    }

    return ProjectCommitteeProject(
      id: _readString(json, '_id'),
      projectId: _readString(json, 'projectId'),
      projectName: _readString(json, 'projectName'),
      members: rawMembers
          .map(
            (item) => ProjectCommitteeStudent.fromJson(
              _asJsonObject(item, 'Thông tin sinh viên'),
            ),
          )
          .toList(growable: false),
      guiderName: _readNullableString(json, 'guiderName'),
      guiderId: _readNullableString(json, 'guiderId'),
      reviewerName: _readNullableString(json, 'reviewerName'),
      reviewerId: _readNullableString(json, 'reviewerId'),
      presentationOrder: _readInt(json, 'presentationOrder', fallback: -1),
    );
  }
}

class ProjectCommittee {
  const ProjectCommittee({
    required this.committeeId,
    required this.name,
    required this.members,
    required this.academicYear,
    required this.project,
    this.time,
    this.date,
    this.location,
  });

  final String committeeId;
  final String name;
  final List<ProjectCommitteeMember> members;
  final String? time;
  final DateTime? date;
  final String? location;
  final String academicYear;
  final ProjectCommitteeProject project;

  factory ProjectCommittee.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    if (rawMembers is! List) {
      throw const FormatException(
        'Danh sách thành viên hội đồng không đúng định dạng.',
      );
    }

    return ProjectCommittee(
      committeeId: _readString(json, 'committeeId'),
      name: _readString(json, 'name'),
      members: rawMembers
          .map(
            (item) => ProjectCommitteeMember.fromJson(
              _asJsonObject(item, 'Thông tin thành viên hội đồng'),
            ),
          )
          .toList(growable: false),
      time: _readNullableString(json, 'time'),
      date: _readNullableDate(json, 'date'),
      location: _readNullableString(json, 'location'),
      academicYear: _readString(json, 'academicYear'),
      project: ProjectCommitteeProject.fromJson(
        _asJsonObject(json['project'], 'Thông tin đồ án trong hội đồng'),
      ),
    );
  }
}

Map<String, dynamic> _asJsonObject(Object? value, String label) {
  if (value is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }
  return Map<String, dynamic>.from(value);
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  if (value != null) {
    return value.toString();
  }
  return '';
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  final text = value is String ? value : value.toString();
  return text.isEmpty ? null : text;
}

int _readInt(Map<String, dynamic> json, String key, {required int fallback}) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _readNullableDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null || value.toString().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}

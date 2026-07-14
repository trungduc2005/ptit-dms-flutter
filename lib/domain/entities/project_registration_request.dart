/// Body gửi khi POST hoặc PUT /api/projects
class ProjectRegistrationRequest {
  final String academicYearId;
  final String field;
  final String period;
  final String projectName;
  final String keyword;
  final String description;
  final String outcome;
  final String? guiderId;
  final String? guiderName;

  /// Danh sách thành viên (KHÔNG bao gồm leader - người đang đăng nhập)
  /// Mỗi phần tử chỉ cần {'studentId': 'B23DCKH001'}
  final List<Map<String, dynamic>> members;

  const ProjectRegistrationRequest({
    required this.academicYearId,
    required this.field,
    required this.period,
    required this.projectName,
    required this.keyword,
    required this.description,
    required this.outcome,
    this.guiderId,
    this.guiderName,
    this.members = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'academicYearId': academicYearId,
      'field': field,
      'period': period,
      'projectName': projectName,
      'keyword': keyword,
      'description': description,
      'outcome': outcome,
      if (guiderId != null) 'guiderId': guiderId,
      if (guiderName != null) 'guiderName': guiderName,
      'members': members,
    };
  }
}
/// Body gửi khi tạo hoặc cập nhật báo cáo tiến độ đồ án.
///
/// [projectId] là mã nghiệp vụ của đồ án, không phải MongoDB `_id`.
class ProjectProgressReportRequest {
  const ProjectProgressReportRequest({
    required this.projectId,
    required this.key,
    required this.brief,
    required this.difficulty,
    required this.expectation,
    required this.link,
    required this.academicYearId,
  });

  final String projectId;
  final String key;
  final String brief;
  final String difficulty;
  final String expectation;
  final String link;
  final String academicYearId;

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'key': key,
      'brief': brief,
      'difficulty': difficulty,
      'expectation': expectation,
      'link': link,
      'academicYearId': academicYearId,
    };
  }
}

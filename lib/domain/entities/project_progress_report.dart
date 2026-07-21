class ProjectReportReply {
  const ProjectReportReply({
    required this.key,
    required this.brief,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  final String key;
  final String brief;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProjectReportReply.fromJson(Map<String, dynamic> json) {
    return ProjectReportReply(
      key: _requiredString(json, 'key'),
      brief: _requiredString(json, 'brief'),
      content: _requiredString(json, 'reply'),
      createdAt: _optionalDateTime(json['createdAt']),
      updatedAt: _optionalDateTime(json['updatedAt']),
    );
  }
}

class ProjectProgressReport {
  const ProjectProgressReport({
    required this.id,
    required this.projectId,
    required this.key,
    required this.brief,
    required this.difficulty,
    required this.expectation,
    required this.link,
    this.projectRef,
    this.replies = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? projectRef;
  final String projectId;
  final String key;
  final String brief;
  final String difficulty;
  final String expectation;
  final String link;
  final List<ProjectReportReply> replies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProjectProgressReport.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    final replies = rawReplies == null
        ? const <ProjectReportReply>[]
        : rawReplies is List
        ? rawReplies
              .map((item) {
                if (item is! Map) {
                  throw const FormatException(
                    'Phản hồi báo cáo không đúng định dạng.',
                  );
                }
                return ProjectReportReply.fromJson(
                  Map<String, dynamic>.from(item),
                );
              })
              .toList(growable: false)
        : throw const FormatException(
            'Danh sách phản hồi báo cáo không đúng định dạng.',
          );

    return ProjectProgressReport(
      id: _requiredString(json, '_id'),
      projectRef: _optionalReferenceId(json['projectRef']),
      projectId: _requiredString(json, 'projectId'),
      key: _requiredString(json, 'key'),
      brief: _requiredString(json, 'brief'),
      difficulty: _requiredString(json, 'difficulty'),
      expectation: _requiredString(json, 'expectation'),
      link: _requiredString(json, 'link'),
      replies: replies,
      createdAt: _optionalDateTime(json['createdAt']),
      updatedAt: _optionalDateTime(json['updatedAt']),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();

  throw FormatException('Trường "$key" không hợp lệ.');
}

String? _optionalReferenceId(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
  if (value is Map) {
    final id = value['_id'];
    if (id is String && id.trim().isNotEmpty) return id.trim();
  }
  throw const FormatException('Tham chiếu đồ án không hợp lệ.');
}

DateTime? _optionalDateTime(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Thời gian báo cáo không hợp lệ.');
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw const FormatException('Thời gian báo cáo không hợp lệ.');
  }
  return parsed;
}

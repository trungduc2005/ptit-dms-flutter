enum ProjectPreDefenseSubmissionStatus {
  pending,
  approved,
  rejected;

  static ProjectPreDefenseSubmissionStatus fromJson(Object? value) {
    if (value is! String) {
      throw const FormatException('Trạng thái nộp đồ án không hợp lệ.');
    }

    return switch (value.trim()) {
      'pending' => ProjectPreDefenseSubmissionStatus.pending,
      'approved' => ProjectPreDefenseSubmissionStatus.approved,
      'rejected' => ProjectPreDefenseSubmissionStatus.rejected,
      _ => throw FormatException(
        'Trạng thái nộp đồ án không được hỗ trợ: "$value".',
      ),
    };
  }
}

class ProjectPreDefenseFile {
  const ProjectPreDefenseFile({
    required this.fileName,
    required this.fileKey,
    required this.fileType,
  });

  final String fileName;
  final String fileKey;
  final String fileType;

  factory ProjectPreDefenseFile.fromJson(Map<String, dynamic> json) {
    return ProjectPreDefenseFile(
      fileName: _requiredString(json, 'fileName'),
      fileKey: _requiredString(json, 'fileKey'),
      fileType: _requiredString(json, 'fileType'),
    );
  }
}

class ProjectPreDefenseApproval {
  const ProjectPreDefenseApproval({
    required this.status,
    this.approverRef,
    this.comment,
    this.approvedAt,
  });

  final ProjectPreDefenseSubmissionStatus status;
  final String? approverRef;
  final String? comment;
  final DateTime? approvedAt;

  factory ProjectPreDefenseApproval.fromJson(Map<String, dynamic> json) {
    return ProjectPreDefenseApproval(
      status: ProjectPreDefenseSubmissionStatus.fromJson(json['status']),
      approverRef: _optionalReferenceId(json['approverRef']),
      comment: _optionalString(json['comment']),
      approvedAt: _optionalDateTime(json['approvedAt']),
    );
  }
}

class ProjectPreDefenseSubmissionAttempt {
  const ProjectPreDefenseSubmissionAttempt({
    required this.files,
    required this.guiderApproval,
    this.uploadedAt,
  });

  final List<ProjectPreDefenseFile> files;
  final ProjectPreDefenseApproval guiderApproval;
  final DateTime? uploadedAt;

  factory ProjectPreDefenseSubmissionAttempt.fromJson(
    Map<String, dynamic> json,
  ) {
    final approval = _requiredMap(json['approval'], label: 'thông tin duyệt');
    final guider = _requiredMap(
      approval['guider'],
      label: 'thông tin duyệt của giảng viên',
    );

    return ProjectPreDefenseSubmissionAttempt(
      files: _requiredList(
        json['files'],
        ProjectPreDefenseFile.fromJson,
        label: 'danh sách file đã nộp',
      ),
      guiderApproval: ProjectPreDefenseApproval.fromJson(guider),
      uploadedAt: _optionalDateTime(json['uploadedAt']),
    );
  }
}

class ProjectPreDefenseSubmission {
  const ProjectPreDefenseSubmission({required this.submissions, this.status});

  final List<ProjectPreDefenseSubmissionAttempt> submissions;
  final ProjectPreDefenseSubmissionStatus? status;

  bool get hasSubmitted => submissions.isNotEmpty;

  ProjectPreDefenseSubmissionAttempt? get latestSubmission =>
      submissions.isEmpty ? null : submissions.last;

  bool get canResubmit =>
      !hasSubmitted || status == ProjectPreDefenseSubmissionStatus.rejected;

  factory ProjectPreDefenseSubmission.fromJson(Map<String, dynamic> json) {
    final rawSubmissions = json['submissions'];

    // Backend trả về {"success": true, "files": []} khi chưa có bản nộp.
    if (rawSubmissions == null) {
      final rawFiles = json['files'];
      if (rawFiles is List && rawFiles.isEmpty) {
        return const ProjectPreDefenseSubmission(submissions: []);
      }
      throw const FormatException('Dữ liệu nộp đồ án không đúng định dạng.');
    }

    final submissions = _requiredList(
      rawSubmissions,
      ProjectPreDefenseSubmissionAttempt.fromJson,
      label: 'lịch sử nộp đồ án',
    );

    final rawStatus = json['status'];
    if (submissions.isNotEmpty && rawStatus == null) {
      throw const FormatException('Thiếu trạng thái nộp đồ án.');
    }

    return ProjectPreDefenseSubmission(
      submissions: submissions,
      status: rawStatus == null
          ? null
          : ProjectPreDefenseSubmissionStatus.fromJson(rawStatus),
    );
  }
}

List<T> _requiredList<T>(
  Object? value,
  T Function(Map<String, dynamic>) fromJson, {
  required String label,
}) {
  if (value is! List) {
    throw FormatException('$label không đúng định dạng.');
  }

  return value
      .map((item) {
        if (item is! Map) {
          throw FormatException('Phần tử trong $label không đúng định dạng.');
        }
        return fromJson(Map<String, dynamic>.from(item));
      })
      .toList(growable: false);
}

Map<String, dynamic> _requiredMap(Object? value, {required String label}) {
  if (value is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }
  return Map<String, dynamic>.from(value);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();

  throw FormatException('Trường "$key" không hợp lệ.');
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Giá trị văn bản không hợp lệ.');
  }

  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
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

  throw const FormatException('Tham chiếu người duyệt không hợp lệ.');
}

DateTime? _optionalDateTime(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Thời gian nộp đồ án không hợp lệ.');
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw const FormatException('Thời gian nộp đồ án không hợp lệ.');
  }
  return parsed;
}

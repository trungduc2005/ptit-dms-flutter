enum ProjectPostDefenseSubmissionStatus {
  pending,
  approved,
  rejected;

  static ProjectPostDefenseSubmissionStatus fromJson(Object? value) {
    if (value is! String) {
      throw const FormatException('Trạng thái nộp đồ án không hợp lệ.');
    }

    return switch (value.trim()) {
      'pending' => ProjectPostDefenseSubmissionStatus.pending,
      'approved' => ProjectPostDefenseSubmissionStatus.approved,
      'rejected' => ProjectPostDefenseSubmissionStatus.rejected,
      _ => throw FormatException(
        'Trạng thái nộp đồ án không được hỗ trợ: "$value".',
      ),
    };
  }
}

class ProjectPostDefenseFile {
  const ProjectPostDefenseFile({
    required this.fileName,
    required this.fileKey,
    required this.fileType,
  });

  final String fileName;
  final String fileKey;
  final String fileType;

  factory ProjectPostDefenseFile.fromJson(Map<String, dynamic> json) {
    return ProjectPostDefenseFile(
      fileName: _requiredString(json, 'fileName'),
      fileKey: _requiredString(json, 'fileKey'),
      fileType: _requiredString(json, 'fileType'),
    );
  }
}

class ProjectPostDefenseApproval {
  const ProjectPostDefenseApproval({
    required this.status,
    this.approverRef,
    this.comment,
    this.approvedAt,
  });

  final ProjectPostDefenseSubmissionStatus status;
  final String? approverRef;
  final String? comment;
  final DateTime? approvedAt;

  factory ProjectPostDefenseApproval.fromJson(Map<String, dynamic> json) {
    return ProjectPostDefenseApproval(
      status: ProjectPostDefenseSubmissionStatus.fromJson(json['status']),
      approverRef: _optionalReferenceId(json['approverRef']),
      comment: _optionalString(json['comment']),
      approvedAt: _optionalDateTime(json['approvedAt']),
    );
  }
}

class ProjectPostDefenseSubmissionAttempt {
  const ProjectPostDefenseSubmissionAttempt({
    required this.files,
    required this.guiderApproval,
    required this.committeeApproval,
    this.uploadedAt,
  });

  final List<ProjectPostDefenseFile> files;
  final ProjectPostDefenseApproval guiderApproval;
  final ProjectPostDefenseApproval committeeApproval;
  final DateTime? uploadedAt;

  factory ProjectPostDefenseSubmissionAttempt.fromJson(
    Map<String, dynamic> json,
  ) {
    final approval = _requiredMap(json['approval'], label: 'thông tin duyệt');

    return ProjectPostDefenseSubmissionAttempt(
      files: _requiredList(
        json['files'],
        ProjectPostDefenseFile.fromJson,
        label: 'danh sách file đã nộp',
      ),
      guiderApproval: ProjectPostDefenseApproval.fromJson(
        _requiredMap(
          approval['guider'],
          label: 'thông tin duyệt của giảng viên',
        ),
      ),
      committeeApproval: ProjectPostDefenseApproval.fromJson(
        _requiredMap(
          approval['committee'],
          label: 'thông tin duyệt của hội đồng',
        ),
      ),
      uploadedAt: _optionalDateTime(json['uploadedAt']),
    );
  }
}

class ProjectPostDefenseSubmission {
  const ProjectPostDefenseSubmission({
    required this.submissions,
    this.guiderApprovalStatus,
    this.committeeApprovalStatus,
  });

  final List<ProjectPostDefenseSubmissionAttempt> submissions;
  final ProjectPostDefenseSubmissionStatus? guiderApprovalStatus;
  final ProjectPostDefenseSubmissionStatus? committeeApprovalStatus;

  bool get hasSubmitted => submissions.isNotEmpty;

  ProjectPostDefenseSubmissionAttempt? get latestSubmission =>
      submissions.isEmpty ? null : submissions.last;

  bool get canResubmit =>
      !hasSubmitted ||
      guiderApprovalStatus == ProjectPostDefenseSubmissionStatus.rejected ||
      committeeApprovalStatus == ProjectPostDefenseSubmissionStatus.rejected;

  bool get isFullyApproved =>
      guiderApprovalStatus == ProjectPostDefenseSubmissionStatus.approved &&
      committeeApprovalStatus == ProjectPostDefenseSubmissionStatus.approved;

  factory ProjectPostDefenseSubmission.fromJson(Map<String, dynamic> json) {
    final rawSubmissions = json['submissions'];

    // Backend trả về {"success": true, "files": []} khi chưa có bản nộp.
    if (rawSubmissions == null) {
      final rawFiles = json['files'];
      if (rawFiles is List && rawFiles.isEmpty) {
        return const ProjectPostDefenseSubmission(submissions: []);
      }
      throw const FormatException('Dữ liệu nộp đồ án không đúng định dạng.');
    }

    final submissions = _requiredList(
      rawSubmissions,
      ProjectPostDefenseSubmissionAttempt.fromJson,
      label: 'lịch sử nộp đồ án',
    );

    final rawGuiderStatus = json['guiderApprovalStatus'];
    final rawCommitteeStatus = json['committeeApprovalStatus'];
    if (submissions.isNotEmpty &&
        (rawGuiderStatus == null || rawCommitteeStatus == null)) {
      throw const FormatException('Thiếu trạng thái duyệt đồ án.');
    }

    return ProjectPostDefenseSubmission(
      submissions: submissions,
      guiderApprovalStatus: rawGuiderStatus == null
          ? null
          : ProjectPostDefenseSubmissionStatus.fromJson(rawGuiderStatus),
      committeeApprovalStatus: rawCommitteeStatus == null
          ? null
          : ProjectPostDefenseSubmissionStatus.fromJson(rawCommitteeStatus),
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

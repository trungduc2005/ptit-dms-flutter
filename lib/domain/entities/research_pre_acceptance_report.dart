enum ResearchPreAcceptanceReportStatus {
  pending,
  approved,
  rejected;

  static ResearchPreAcceptanceReportStatus fromJson(Object? value) {
    if (value is! String) {
      throw const FormatException(
        'Trạng thái báo cáo trước nghiệm thu không hợp lệ.',
      );
    }

    return switch (value.trim()) {
      'pending' => ResearchPreAcceptanceReportStatus.pending,
      'approved' => ResearchPreAcceptanceReportStatus.approved,
      'rejected' => ResearchPreAcceptanceReportStatus.rejected,
      _ => throw FormatException(
        'Trạng thái báo cáo trước nghiệm thu không được hỗ trợ: "$value".',
      ),
    };
  }
}

class ResearchPreAcceptanceReportFile {
  const ResearchPreAcceptanceReportFile({
    required this.fileName,
    required this.fileKey,
    required this.fileType,
    this.fileUrl,
  });

  final String fileName;
  final String fileKey;
  final String fileType;
  final String? fileUrl;

  factory ResearchPreAcceptanceReportFile.fromJson(Map<String, dynamic> json) {
    return ResearchPreAcceptanceReportFile(
      fileName: _requiredString(json, 'fileName'),
      fileKey: _requiredString(json, 'fileKey'),
      fileType: _requiredString(json, 'fileType'),
      fileUrl: _optionalString(json['fileUrl']),
    );
  }
}

class ResearchPreAcceptanceReport {
  const ResearchPreAcceptanceReport({
    required this.order,
    required this.researchId,
    required this.researchTopic,
    required this.reportFile,
    required this.turnitinReportFile,
    required this.submissionDate,
    required this.status,
    required this.comment,
    this.reviewerId,
    this.reviewerName,
    this.reviewedAt,
  });

  final int order;
  final String researchId;
  final String researchTopic;
  final ResearchPreAcceptanceReportFile reportFile;
  final ResearchPreAcceptanceReportFile turnitinReportFile;
  final DateTime submissionDate;
  final ResearchPreAcceptanceReportStatus status;
  final String comment;
  final String? reviewerId;
  final String? reviewerName;
  final DateTime? reviewedAt;

  factory ResearchPreAcceptanceReport.fromJson(Map<String, dynamic> json) {
    return ResearchPreAcceptanceReport(
      order: _requiredPositiveInt(json, 'numOrder'),
      researchId: _requiredString(json, 'researchId'),
      researchTopic: _requiredString(json, 'researchTopic'),
      reportFile: ResearchPreAcceptanceReportFile.fromJson(
        _requiredMap(json['reportFile'], label: 'quyển báo cáo'),
      ),
      turnitinReportFile: ResearchPreAcceptanceReportFile.fromJson(
        _requiredMap(
          json['turnitinReportFile'],
          label: 'báo cáo kiểm tra đạo văn',
        ),
      ),
      submissionDate: _requiredDateTime(
        json['submissionDate'],
        label: 'thời gian nộp báo cáo',
      ),
      status: ResearchPreAcceptanceReportStatus.fromJson(
        json['submissionStatus'],
      ),
      comment: _optionalString(json['comment']) ?? '',
      reviewerId: _optionalString(json['reviewerId']),
      reviewerName: _optionalString(json['reviewerName']),
      reviewedAt: _optionalDateTime(
        json['reviewedAt'],
        label: 'thời gian duyệt báo cáo',
      ),
    );
  }
}

Map<String, dynamic> _requiredMap(Object? value, {required String label}) {
  if (value is! Map) {
    throw FormatException('$label không đúng định dạng.');
  }

  return Map<String, dynamic>.from(value);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

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

int _requiredPositiveInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int && value > 0) return value;

  throw FormatException('Trường "$key" không hợp lệ.');
}

DateTime _requiredDateTime(Object? value, {required String label}) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }

  throw FormatException('$label không hợp lệ.');
}

DateTime? _optionalDateTime(Object? value, {required String label}) {
  if (value == null) return null;
  return _requiredDateTime(value, label: label);
}

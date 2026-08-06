enum ResearchPostAcceptanceReportStatus {
  submitted;

  static ResearchPostAcceptanceReportStatus fromJson(Object? value) {
    if (value is! String) {
      throw const FormatException(
        'Trạng thái báo cáo sau nghiệm thu không hợp lệ.',
      );
    }

    return switch (value.trim()) {
      'submitted' => ResearchPostAcceptanceReportStatus.submitted,
      _ => throw FormatException(
        'Trạng thái báo cáo sau nghiệm thu không được hỗ trợ: "$value".',
      ),
    };
  }
}

class ResearchPostAcceptanceReportFile {
  const ResearchPostAcceptanceReportFile({
    required this.fileName,
    required this.fileKey,
    required this.fileType,
    required this.fileUrl,
  });

  final String fileName;
  final String fileKey;
  final String fileType;
  final String fileUrl;

  factory ResearchPostAcceptanceReportFile.fromJson(Map<String, dynamic> json) {
    return ResearchPostAcceptanceReportFile(
      fileName: _requiredString(json, 'fileName'),
      fileKey: _requiredString(json, 'fileKey'),
      fileType: _requiredString(json, 'fileType'),
      fileUrl: _requiredString(json, 'fileUrl'),
    );
  }
}

class ResearchPostAcceptanceReport {
  const ResearchPostAcceptanceReport({
    required this.order,
    required this.researchId,
    required this.researchTopic,
    required this.reportFile,
    required this.acceptanceMinutesFile,
    required this.acceptanceCommitteeListFile,
    required this.proposalFile,
    required this.revisionExplanationFile,
    required this.acceptanceDecisionFile,
    required this.submissionDate,
    required this.status,
    this.paperFile,
  });

  final int order;
  final String researchId;
  final String researchTopic;
  final ResearchPostAcceptanceReportFile reportFile;
  final ResearchPostAcceptanceReportFile acceptanceMinutesFile;
  final ResearchPostAcceptanceReportFile acceptanceCommitteeListFile;
  final ResearchPostAcceptanceReportFile proposalFile;
  final ResearchPostAcceptanceReportFile revisionExplanationFile;
  final ResearchPostAcceptanceReportFile acceptanceDecisionFile;
  final ResearchPostAcceptanceReportFile? paperFile;
  final DateTime submissionDate;
  final ResearchPostAcceptanceReportStatus status;

  factory ResearchPostAcceptanceReport.fromJson(Map<String, dynamic> json) {
    return ResearchPostAcceptanceReport(
      order: _requiredPositiveInt(json, 'numOrder'),
      researchId: _requiredString(json, 'researchId'),
      researchTopic: _requiredString(json, 'researchTopic'),
      reportFile: ResearchPostAcceptanceReportFile.fromJson(
        _requiredMap(json['reportFile'], label: 'báo cáo'),
      ),
      acceptanceMinutesFile: ResearchPostAcceptanceReportFile.fromJson(
        _requiredMap(
          json['acceptanceMinutesFile'],
          label: 'biên bản nghiệm thu',
        ),
      ),
      acceptanceCommitteeListFile: ResearchPostAcceptanceReportFile.fromJson(
        _requiredMap(
          json['acceptanceCommitteeListFile'],
          label: 'danh sách hội đồng nghiệm thu',
        ),
      ),
      proposalFile: ResearchPostAcceptanceReportFile.fromJson(
        _requiredMap(json['proposalFile'], label: 'đề cương'),
      ),
      revisionExplanationFile: ResearchPostAcceptanceReportFile.fromJson(
        _requiredMap(
          json['revisionExplanationFile'],
          label: 'giải trình chỉnh sửa',
        ),
      ),
      acceptanceDecisionFile: ResearchPostAcceptanceReportFile.fromJson(
        _requiredMap(
          json['acceptanceDecisionFile'],
          label: 'quyết định nghiệm thu',
        ),
      ),
      paperFile: _optionalFile(json['paperFile'], label: 'paper'),
      submissionDate: _requiredDateTime(
        json['submissionDate'],
        label: 'thời gian nộp báo cáo',
      ),
      status: ResearchPostAcceptanceReportStatus.fromJson(
        json['submissionStatus'],
      ),
    );
  }
}

ResearchPostAcceptanceReportFile? _optionalFile(
  Object? value, {
  required String label,
}) {
  if (value == null) return null;

  return ResearchPostAcceptanceReportFile.fromJson(
    _requiredMap(value, label: label),
  );
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

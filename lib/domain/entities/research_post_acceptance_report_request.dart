import 'dart:typed_data';

enum ResearchPostAcceptanceSubmitterType { student, lecturer }

class ResearchPostAcceptanceUploadFile {
  const ResearchPostAcceptanceUploadFile({
    required this.fileName,
    this.path,
    this.bytes,
    this.size,
  }) : assert(path != null || bytes != null);

  final String fileName;
  final String? path;
  final Uint8List? bytes;
  final int? size;

  int? get effectiveSize => size ?? bytes?.lengthInBytes;
}

class ResearchPostAcceptanceReportRequest {
  const ResearchPostAcceptanceReportRequest({
    required this.researchId,
    required this.yearId,
    required this.submitterType,
    required this.reportFile,
    required this.acceptanceMinutesFile,
    required this.acceptanceCommitteeListFile,
    required this.proposalFile,
    required this.revisionExplanationFile,
    required this.acceptanceDecisionFile,
    this.paperFile,
  });

  static const int maxFileSizeInBytes = 10 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'pdf', 'doc', 'docx'};

  final String researchId;
  final String yearId;
  final ResearchPostAcceptanceSubmitterType submitterType;
  final ResearchPostAcceptanceUploadFile reportFile;
  final ResearchPostAcceptanceUploadFile acceptanceMinutesFile;
  final ResearchPostAcceptanceUploadFile acceptanceCommitteeListFile;
  final ResearchPostAcceptanceUploadFile proposalFile;
  final ResearchPostAcceptanceUploadFile revisionExplanationFile;
  final ResearchPostAcceptanceUploadFile acceptanceDecisionFile;
  final ResearchPostAcceptanceUploadFile? paperFile;

  void validate() {
    if (researchId.trim().isEmpty || yearId.trim().isEmpty) {
      throw const FormatException(
        'Thiếu thông tin đề tài nghiên cứu hoặc năm học.',
      );
    }

    _validateFile(reportFile, label: 'báo cáo');
    _validateFile(acceptanceMinutesFile, label: 'biên bản nghiệm thu');
    _validateFile(
      acceptanceCommitteeListFile,
      label: 'danh sách hội đồng nghiệm thu',
    );
    _validateFile(proposalFile, label: 'đề cương');
    _validateFile(revisionExplanationFile, label: 'giải trình chỉnh sửa');
    _validateFile(acceptanceDecisionFile, label: 'quyết định nghiệm thu');

    final paper = paperFile;
    if (submitterType == ResearchPostAcceptanceSubmitterType.lecturer &&
        paper == null) {
      throw const FormatException('Giảng viên cần tải lên paper.');
    }
    if (paper != null) {
      _validateFile(paper, label: 'paper');
    }
  }

  static void _validateFile(
    ResearchPostAcceptanceUploadFile file, {
    required String label,
  }) {
    final fileName = file.fileName.trim();
    final extensionSeparator = fileName.lastIndexOf('.');
    if (extensionSeparator <= 0 || extensionSeparator == fileName.length - 1) {
      throw FormatException('$label không có phần mở rộng hợp lệ.');
    }

    final extension = fileName.substring(extensionSeparator + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw FormatException('$label phải có định dạng PDF, DOC hoặc DOCX.');
    }

    final size = file.effectiveSize;
    if (size != null && size <= 0) {
      throw FormatException('$label không có dữ liệu.');
    }
    if (size != null && size > maxFileSizeInBytes) {
      throw FormatException('$label vượt quá giới hạn 10 MB.');
    }

    final path = file.path;
    if (file.bytes == null && (path == null || path.trim().isEmpty)) {
      throw FormatException('Không thể đọc $label đã chọn.');
    }
  }
}

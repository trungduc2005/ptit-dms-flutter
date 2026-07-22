import 'dart:typed_data';

class ProjectPostDefenseUploadFile {
  const ProjectPostDefenseUploadFile({
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

class ProjectPostDefenseSubmissionRequest {
  const ProjectPostDefenseSubmissionRequest({
    required this.projectId,
    required this.academicYearId,
    required this.thesisFile,
    required this.responseCommitteeFile,
    required this.approvalMinutesFile,
    required this.sourceFile,
  });

  static const int maxFileSizeInBytes = 25 * 1024 * 1024;
  static const Set<String> documentExtensions = {'pdf', 'doc', 'docx'};
  static const Set<String> sourceExtensions = {'zip'};

  final String projectId;
  final String academicYearId;
  final ProjectPostDefenseUploadFile thesisFile;
  final ProjectPostDefenseUploadFile responseCommitteeFile;
  final ProjectPostDefenseUploadFile approvalMinutesFile;
  final ProjectPostDefenseUploadFile sourceFile;

  void validate() {
    if (projectId.trim().isEmpty || academicYearId.trim().isEmpty) {
      throw const FormatException('Thiếu thông tin đồ án hoặc năm học.');
    }

    _validateFile(
      thesisFile,
      label: 'file quyển đồ án',
      allowedExtensions: documentExtensions,
      allowedFormatMessage: 'PDF, DOC hoặc DOCX',
    );
    _validateFile(
      responseCommitteeFile,
      label: 'file giải trình chỉnh sửa',
      allowedExtensions: documentExtensions,
      allowedFormatMessage: 'PDF, DOC hoặc DOCX',
    );
    _validateFile(
      approvalMinutesFile,
      label: 'file biên bản xác nhận',
      allowedExtensions: documentExtensions,
      allowedFormatMessage: 'PDF, DOC hoặc DOCX',
    );
    _validateFile(
      sourceFile,
      label: 'file sản phẩm kèm theo',
      allowedExtensions: sourceExtensions,
      allowedFormatMessage: 'ZIP',
    );
  }

  static void _validateFile(
    ProjectPostDefenseUploadFile file, {
    required String label,
    required Set<String> allowedExtensions,
    required String allowedFormatMessage,
  }) {
    final fileName = file.fileName.trim();
    final extensionSeparator = fileName.lastIndexOf('.');
    if (extensionSeparator <= 0 || extensionSeparator == fileName.length - 1) {
      throw FormatException('$label không có phần mở rộng hợp lệ.');
    }

    final extension = fileName.substring(extensionSeparator + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw FormatException('$label phải có định dạng $allowedFormatMessage.');
    }

    final size = file.effectiveSize;
    if (size != null && size > maxFileSizeInBytes) {
      throw FormatException('$label vượt quá giới hạn 25 MB.');
    }
    if (size != null && size <= 0) {
      throw FormatException('$label không có dữ liệu.');
    }

    final path = file.path;
    if (file.bytes == null && (path == null || path.trim().isEmpty)) {
      throw FormatException('Không thể đọc $label đã chọn.');
    }
  }
}

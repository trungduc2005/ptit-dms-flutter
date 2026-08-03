import 'dart:typed_data';

class ResearchPreAcceptanceUploadFile {
  const ResearchPreAcceptanceUploadFile({
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

class ResearchPreAcceptanceReportRequest {
  const ResearchPreAcceptanceReportRequest({
    required this.researchId,
    required this.yearId,
    required this.reportFile,
    required this.turnitinReportFile,
  });

  static const int maxFileSizeInBytes = 10 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'pdf', 'doc', 'docx'};

  final String researchId;
  final String yearId;
  final ResearchPreAcceptanceUploadFile reportFile;
  final ResearchPreAcceptanceUploadFile turnitinReportFile;

  void validate() {
    if (researchId.trim().isEmpty || yearId.trim().isEmpty) {
      throw const FormatException(
        'Thiếu thông tin đề tài nghiên cứu hoặc năm học.',
      );
    }

    _validateFile(reportFile, label: 'quyển báo cáo');
    _validateFile(turnitinReportFile, label: 'báo cáo kiểm tra đạo văn');
  }

  static void _validateFile(
    ResearchPreAcceptanceUploadFile file, {
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

import 'dart:typed_data';

class ProjectPreDefenseUploadFile {
  const ProjectPreDefenseUploadFile({
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

class ProjectPreDefenseSubmissionRequest {
  const ProjectPreDefenseSubmissionRequest({
    required this.projectId,
    required this.academicYearId,
    this.thesisFile,
    this.turnitinReportFile,
  });

  static const int maxFileSizeInBytes = 25 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'pdf', 'doc', 'docx'};

  final String projectId;
  final String academicYearId;
  final ProjectPreDefenseUploadFile? thesisFile;
  final ProjectPreDefenseUploadFile? turnitinReportFile;

  void validate() {
    if (projectId.trim().isEmpty || academicYearId.trim().isEmpty) {
      throw const FormatException('Thiếu thông tin đồ án hoặc năm học.');
    }
    if (thesisFile == null && turnitinReportFile == null) {
      throw const FormatException('Cần chọn ít nhất một file để nộp.');
    }

    if (thesisFile != null) {
      _validateFile(thesisFile!, label: 'file quyển đồ án');
    }
    if (turnitinReportFile != null) {
      _validateFile(turnitinReportFile!, label: 'file báo cáo Turnitin');
    }
  }

  static void _validateFile(
    ProjectPreDefenseUploadFile file, {
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
    if (size != null && size > maxFileSizeInBytes) {
      throw FormatException('$label vượt quá giới hạn 25 MB.');
    }
    if (size != null && size <= 0) {
      throw FormatException('$label không có dữ liệu.');
    }
  }
}

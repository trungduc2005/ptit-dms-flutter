import 'dart:typed_data';

class ResearchPostAcceptanceReportDownload {
  const ResearchPostAcceptanceReportDownload({
    required this.bytes,
    required this.fileName,
    this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String? contentType;
}

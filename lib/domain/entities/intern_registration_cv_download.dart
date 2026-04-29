import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class InternRegistrationCvDownload extends Equatable {
  const InternRegistrationCvDownload({
    required this.bytes,
    required this.fileName,
    this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String? contentType;

  int get length => bytes.lengthInBytes;

  @override
  List<Object?> get props => [bytes, fileName, contentType];
}

import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class InternRegistrationAcceptedCompanyProof extends Equatable {
  const InternRegistrationAcceptedCompanyProof({
    required this.proofType,
    required this.contactName,
    required this.contactPhone,
    required this.contactPosition,
    required this.evidenceFile,
  });

  final String proofType;
  final String contactName;
  final String contactPhone;
  final String contactPosition;
  final InternRegistrationEvidenceFile evidenceFile;

  factory InternRegistrationAcceptedCompanyProof.fromJson(
    Map<String, dynamic> json,
  ) {
    final evidenceFileJson = json['evidenceFile'];

    return InternRegistrationAcceptedCompanyProof(
      proofType: asString(json['proofType']) ?? '',
      contactName: asString(json['contactName']) ?? '',
      contactPhone: asString(json['contactPhone']) ?? '',
      contactPosition: asString(json['contactPosition']) ?? '',
      evidenceFile: evidenceFileJson is Map
          ? InternRegistrationEvidenceFile.fromJson(
              Map<String, dynamic>.from(evidenceFileJson),
            )
          : const InternRegistrationEvidenceFile(
              fileName: '',
              fileKey: '',
              fileType: '',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proofType': proofType,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactPosition': contactPosition,
      'evidenceFile': evidenceFile.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    proofType,
    contactName,
    contactPhone,
    contactPosition,
    evidenceFile,
  ];
}

class InternRegistrationEvidenceFile extends Equatable {
  const InternRegistrationEvidenceFile({
    required this.fileName,
    required this.fileKey,
    required this.fileType,
    this.uploadedAt,
  });

  final String fileName;
  final String fileKey;
  final String fileType;
  final DateTime? uploadedAt;

  factory InternRegistrationEvidenceFile.fromJson(Map<String, dynamic> json) {
    return InternRegistrationEvidenceFile(
      fileName: asString(json['fileName']) ?? '',
      fileKey: asString(json['fileKey']) ?? '',
      fileType: asString(json['fileType']) ?? '',
      uploadedAt: asDateTime(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileKey': fileKey,
      'fileType': fileType,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [fileName, fileKey, fileType, uploadedAt];
}

class InternRegistrationEvidenceUploadResult extends Equatable {
  const InternRegistrationEvidenceUploadResult({
    required this.evidenceFileName,
    required this.evidenceFileKey,
    required this.evidenceFileType,
  });

  final String evidenceFileName;
  final String evidenceFileKey;
  final String evidenceFileType;

  InternRegistrationEvidenceFile get evidenceFile =>
      InternRegistrationEvidenceFile(
        fileName: evidenceFileName,
        fileKey: evidenceFileKey,
        fileType: evidenceFileType,
      );

  factory InternRegistrationEvidenceUploadResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return InternRegistrationEvidenceUploadResult(
      evidenceFileName: asString(json['evidenceFileName']) ?? '',
      evidenceFileKey: asString(json['evidenceFileKey']) ?? '',
      evidenceFileType: asString(json['evidenceFileType']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evidenceFileName': evidenceFileName,
      'evidenceFileKey': evidenceFileKey,
      'evidenceFileType': evidenceFileType,
    };
  }

  @override
  List<Object?> get props => [
    evidenceFileName,
    evidenceFileKey,
    evidenceFileType,
  ];
}

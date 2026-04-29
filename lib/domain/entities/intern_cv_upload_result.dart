import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class InternCvUploadResult extends Equatable {
  const InternCvUploadResult({
    required this.cvFileKey,
    required this.cvFileName,
  });

  final String cvFileName;
  final String cvFileKey;

  factory InternCvUploadResult.fromJson(Map<String, dynamic> json) {
    return InternCvUploadResult(
      cvFileKey: asString(json['cvFileKey']) ?? '',
      cvFileName: asString(json['cvFileName']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'cvFileName': cvFileName, 'cvFileKey': cvFileKey};
  }

  @override
  List<Object?> get props => [cvFileName, cvFileKey];
}

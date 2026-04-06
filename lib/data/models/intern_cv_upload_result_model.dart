import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class InternCvUploadResultModel extends Equatable {
  InternCvUploadResultModel({
    required this.cvFileKey,
    required this.cvFileName,
  });

  final String cvFileName;
  final String cvFileKey;

  factory InternCvUploadResultModel.fromJson(Map<String, dynamic> json) {
    return InternCvUploadResultModel(
      cvFileKey: asString(json['cvFileKey']) ?? '',
      cvFileName: asString(json['cvFileName']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cvFileName': cvFileName, 
      'cvFileKey': cvFileKey, 
    };
  }

  @override
  List<Object?> get props => [cvFileName, cvFileKey];
}

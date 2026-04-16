import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/data/models/model_parsers.dart';

class StudentProfileAvatarUploadModel extends Equatable {
  const StudentProfileAvatarUploadModel({
    required this.success,
    this.imageUrl,
  });

  final bool success;
  final String? imageUrl;

  factory StudentProfileAvatarUploadModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentProfileAvatarUploadModel(
      success: asBool(json['success']) ?? false,
      imageUrl: asString(json['imageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [success, imageUrl];
}

import 'package:equatable/equatable.dart';
import 'package:ptit_dms_flutter/core/utils/model_parsers.dart';

class AvatarUploadResult extends Equatable {
  const AvatarUploadResult({required this.success, this.imageUrl});

  final bool success;
  final String? imageUrl;

  factory AvatarUploadResult.fromJson(Map<String, dynamic> json) {
    return AvatarUploadResult(
      success: asBool(json['success']) ?? false,
      imageUrl: asString(json['imageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'imageUrl': imageUrl};
  }

  @override
  List<Object?> get props => [success, imageUrl];
}

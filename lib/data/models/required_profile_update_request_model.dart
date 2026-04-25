import 'package:equatable/equatable.dart';

class RequiredProfileUpdateRequestModel extends Equatable {
  const RequiredProfileUpdateRequestModel({
    required this.email,
    required this.phone,
    required this.citizenId,
    this.newPassword,
    this.confirmPassword,
  });

  final String email;
  final String phone;
  final String citizenId;
  final String? newPassword;
  final String? confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'phone': phone.trim(),
      'citizenId': citizenId.trim(),
      if ((newPassword ?? '').isNotEmpty) 'newPassword': newPassword,
      if ((confirmPassword ?? '').isNotEmpty) 'confirmPassword': confirmPassword,
    };
  }

  @override
  List<Object?> get props => [email, phone, citizenId, newPassword, confirmPassword];
}

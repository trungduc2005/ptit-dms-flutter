import 'package:equatable/equatable.dart';

class StudentProfileUpdateRequestModel extends Equatable {
  const StudentProfileUpdateRequestModel({
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
  });

  final String? email;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (address != null) 'address': address,
    };
  }

  @override
  List<Object?> get props => [email, phone, gender, dateOfBirth, address];
}

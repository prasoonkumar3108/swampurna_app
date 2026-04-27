/// Registration request model
class RegisterRequest {
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? birthDate;
  final String password;

  RegisterRequest({
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.birthDate,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'birth_date': birthDate,
      'password': password,
    };
  }
}

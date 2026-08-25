import '../../../../security/authorization/roles.dart';

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.farmName,
    this.inviteCode,
  });

  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? farmName;
  final String? inviteCode;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'password_confirmation': password,
    'role': role.name,
    if (farmName != null) 'farm_name': farmName,
    if (inviteCode != null) 'invite_code': inviteCode,
  };
}

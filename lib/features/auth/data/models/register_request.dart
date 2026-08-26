import '../../../../security/authorization/roles.dart';

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.farmName,
    this.inviteCode,
    this.motherPigCount = 0,
    this.pigletGroups = const [],
    this.pregnantPigCount,
  });

  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final String? farmName;
  final String? inviteCode;
  final int motherPigCount;
  final List<Map<String, dynamic>> pigletGroups;
  final int? pregnantPigCount;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    'password_confirmation': password,
    'role': role.name,
    if (farmName != null) 'farm_name': farmName,
    if (inviteCode != null) 'invite_code': inviteCode,
    if (role == UserRole.farmOwner) ...{
      'mother_pig_count': motherPigCount,
      'piglet_groups': pigletGroups,
      if (pregnantPigCount != null) 'pregnant_pig_count': pregnantPigCount,
    },
  };
}

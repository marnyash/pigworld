import '../../../../security/authorization/roles.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: '${json['id']}',
    name: '${json['name'] ?? ''}',
    email: '${json['email'] ?? ''}',
    phone: json['phone'] as String?,
    role: UserRole.values.firstWhere(
      (role) => role.name == json['role'],
      orElse: () => UserRole.viewer,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role.name,
  };
}

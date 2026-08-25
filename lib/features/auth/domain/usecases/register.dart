import '../../../../security/authorization/roles.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class Register {
  const Register(this.repository);
  final AuthRepository repository;

  Future<Session> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? farmName,
    String? inviteCode,
  }) => repository.register(
    name: name,
    email: email,
    password: password,
    role: role,
    farmName: farmName,
    inviteCode: inviteCode,
  );
}

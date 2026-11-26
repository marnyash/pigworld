import '../repositories/auth_repository.dart';

class ResetPassword {
  const ResetPassword(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String token,
    required String email,
    required String password,
  }) =>
      repository.resetPassword(token: token, email: email, password: password);
}

import '../repositories/auth_repository.dart';

class VerifyPasswordResetCode {
  const VerifyPasswordResetCode(this.repository);

  final AuthRepository repository;

  Future<void> call({required String email, required String code}) =>
      repository.verifyPasswordResetCode(email: email, code: code);
}

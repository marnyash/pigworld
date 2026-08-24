import '../entities/farm.dart';
import '../entities/session.dart';

abstract interface class AuthRepository {
  Future<Session> login(String email, String password, {bool rememberMe = false});
  Future<void> logout();
  Future<Session?> refreshSession();
  Future<Session> selectFarm(Farm farm);
  Future<void> forgotPassword(String email);
}

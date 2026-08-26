import '../../../../security/authorization/roles.dart';
import '../entities/farm.dart';
import '../entities/session.dart';

abstract interface class AuthRepository {
  Future<Session> login(
    String email,
    String password, {
    bool rememberMe = false,
  });
  Future<Session> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? farmName,
    String? inviteCode,
    int motherPigCount = 0,
    List<Map<String, dynamic>> pigletGroups = const [],
    int? pregnantPigCount,
  });
  Future<void> logout();
  Future<Session?> refreshSession();
  Future<Session> selectFarm(Farm farm);
  Future<void> forgotPassword(String email);
}

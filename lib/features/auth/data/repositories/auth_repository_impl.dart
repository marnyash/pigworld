import 'package:flutter/foundation.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../security/authorization/roles.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remote, required this.local});

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  @override
  Future<Session> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final response = await remote.login(
        LoginRequest(email: email, password: password, rememberMe: rememberMe),
      );
      final session = response.toEntity();
      await local.saveSession(session);
      return session;
    } on ApiException catch (error) {
      if (kDebugMode &&
          error.statusCode == null &&
          email.trim().toLowerCase() == 'test@example.com' &&
          password == 'password') {
        final session = _offlineDemoSession();
        await local.saveSession(session);
        return session;
      }
      rethrow;
    }
  }

  Session _offlineDemoSession() {
    const farm = Farm(
      id: 'offline-demo-farm',
      name: 'Green Valley Farm',
      location: 'Offline demo workspace',
    );
    return const Session(
      accessToken: 'offline-demo-access-token',
      refreshToken: 'offline-demo-refresh-token',
      user: UserModel(
        id: 'offline-demo-user',
        name: 'Test User',
        email: 'test@example.com',
        role: UserRole.farmOwner,
      ),
      farms: [farm],
      selectedFarm: farm,
    );
  }

  @override
  Future<Session> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? farmName,
    String? inviteCode,
    int motherPigCount = 0,
    List<Map<String, dynamic>> pigletGroups = const [],
    int? pregnantPigCount,
  }) async {
    final response = await remote.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        role: role,
        farmName: farmName,
        inviteCode: inviteCode,
        motherPigCount: motherPigCount,
        pigletGroups: pigletGroups,
        pregnantPigCount: pregnantPigCount,
      ),
    );
    final session = response.toEntity();
    await local.saveSession(session);
    return session;
  }

  @override
  Future<void> logout() async => local.clear();

  @override
  Future<Session?> refreshSession() async {
    final session = await local.readSession();
    if (session == null) return null;
    final response = await remote.refresh(session.refreshToken);
    final refreshed = response.toEntity();
    await local.saveSession(refreshed);
    return refreshed;
  }

  @override
  Future<Session> selectFarm(Farm farm) async {
    final session = await local.readSession();
    if (session == null) throw StateError('No authenticated session.');
    final selected = Session(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      user: session.user,
      farms: session.farms,
      selectedFarm: farm,
    );
    await local.saveSelectedFarm(farm);
    await local.saveSession(selected);
    return selected;
  }

  @override
  Future<void> forgotPassword(String email) => remote.forgotPassword(email);
}

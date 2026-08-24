import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../security/authentication/auth_service.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/session.dart';
import '../models/farm_model.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveSession(Session session) async {
    await _storage.write(key: AuthService.accessTokenKey, value: session.accessToken);
    await _storage.write(key: AuthService.refreshTokenKey, value: session.refreshToken);
    await _storage.write(key: AuthService.userProfileKey, value: jsonEncode(UserModel(id: session.user.id, name: session.user.name, email: session.user.email, role: session.user.role).toJson()));
    if (session.selectedFarm != null) await saveSelectedFarm(session.selectedFarm!);
  }

  @override
  Future<Session?> readSession() async {
    final accessToken = await _storage.read(key: AuthService.accessTokenKey);
    final refreshToken = await _storage.read(key: AuthService.refreshTokenKey);
    final userJson = await _storage.read(key: AuthService.userProfileKey);
    if (accessToken == null || refreshToken == null || userJson == null) return null;
    final user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    final farmJson = await _storage.read(key: AuthService.selectedFarmKey);
    final farm = farmJson == null ? null : FarmModel.fromJson(jsonDecode(farmJson) as Map<String, dynamic>);
    return Session(accessToken: accessToken, refreshToken: refreshToken, user: user, farms: const [], selectedFarm: farm);
  }

  @override
  Future<void> saveSelectedFarm(Farm farm) => _storage.write(key: AuthService.selectedFarmKey, value: jsonEncode(FarmModel(id: farm.id, name: farm.name, location: farm.location).toJson()));

  @override
  Future<void> clear() => _storage.deleteAll();
}

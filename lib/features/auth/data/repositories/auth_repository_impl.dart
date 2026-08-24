import '../../domain/entities/farm.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remote, required this.local});

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  @override
  Future<Session> login(String email, String password, {bool rememberMe = false}) async {
    final response = await remote.login(LoginRequest(email: email, password: password, rememberMe: rememberMe));
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
    final selected = Session(accessToken: session.accessToken, refreshToken: session.refreshToken, user: session.user, farms: session.farms, selectedFarm: farm);
    await local.saveSelectedFarm(farm);
    await local.saveSession(selected);
    return selected;
  }

  @override
  Future<void> forgotPassword(String email) => remote.forgotPassword(email);
}

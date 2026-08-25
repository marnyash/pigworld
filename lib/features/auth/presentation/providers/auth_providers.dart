import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../security/authentication/auth_service.dart';
import '../../data/datasource/auth_local_datasource_impl.dart';
import '../../data/datasource/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/refresh_session.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/select_farm.dart';
import 'auth_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// The server address the user configured in-app, falling back to the build-time default.
/// Lets the app be pointed at a different network (LAN IP, tunnel, or domain) without a rebuild.
final serverUrlProvider = FutureProvider<String>((ref) async {
  final saved = await ServerAddressStorage.read();
  return (saved == null || saved.isEmpty) ? ApiConfig.baseUrl : saved;
});

final dioProvider = Provider<Dio>((ref) {
  final authService = ref.watch(authServiceProvider);
  final dio = DioClient.create(
    authService: authService,
    onSessionExpired: () async {
      await authService.clearSession();
      ref.read(authProvider.notifier).clearSession();
    },
  );
  ref.listen(serverUrlProvider, (previous, next) {
    next.whenData((baseUrl) => dio.options.baseUrl = baseUrl);
  }, fireImmediately: true);
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
    local: AuthLocalDataSourceImpl(),
  ),
);

final loginUseCaseProvider = Provider(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider(
  (ref) => Register(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);
final refreshSessionUseCaseProvider = Provider(
  (ref) => RefreshSession(ref.watch(authRepositoryProvider)),
);
final selectFarmUseCaseProvider = Provider(
  (ref) => SelectFarm(ref.watch(authRepositoryProvider)),
);
final forgotPasswordUseCaseProvider = Provider(
  (ref) => ForgotPassword(ref.watch(authRepositoryProvider)),
);

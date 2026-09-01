import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../security/authorization/roles.dart';

abstract final class RouteGuard {
  static const publicRoutes = {
    '/splash',
    '/login',
    '/forgot-password',
    '/session-expired',
    '/permissions',
    '/language',
    '/country',
    '/account-type',
    '/create-account',
    '/herd-setup',
    '/subscription',
    '/farm-selection',
  };

  static bool isPublic(String location) => publicRoutes.contains(location);

  /// Splash owns the asynchronous session check before entering the shell.
  static String? redirect(BuildContext context, GoRouterState state) {
    if (state.uri.path == '/subscription') {
      final role = ProviderScope.containerOf(
        context,
      ).read(authProvider).valueOrNull?.user.role;
      if (role != UserRole.farmOwner) return '/';
    }
    if (isPublic(state.uri.path)) return null;
    final session = ProviderScope.containerOf(
      context,
    ).read(authProvider).valueOrNull;
    if (session == null) return '/splash';
    if (session.selectedFarm == null) return '/farm-selection';
    return null;
  }
}

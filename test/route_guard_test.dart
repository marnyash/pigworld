import 'package:flutter_test/flutter_test.dart';
import 'package:proj/app/routes/route_guard.dart';
import 'package:proj/features/auth/domain/entities/farm.dart';
import 'package:proj/features/auth/domain/entities/session.dart';
import 'package:proj/features/auth/domain/entities/user.dart';
import 'package:proj/security/authorization/roles.dart';

void main() {
  test('first-run onboarding routes remain public', () {
    expect(RouteGuard.isPublic('/farm-selection'), isTrue);
    expect(RouteGuard.isPublic('/language'), isTrue);
    expect(RouteGuard.isPublic('/app-tutorial'), isFalse);
  });

  test('logged-out users are redirected to splash from protected pages', () {
    expect(RouteGuard.redirectFor(null, '/home'), '/splash');
  });

  test('password reset app link targets home and keeps session guards', () {
    final appHome = Uri.parse('pigworldsmart://open/');

    expect(appHome.host, 'open');
    expect(appHome.path, '/');
    expect(RouteGuard.redirectFor(null, appHome.path), '/splash');

    final session = Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      user: const User(
        id: 'user-1',
        name: 'Test User',
        email: 'user@example.com',
        role: UserRole.farmOwner,
      ),
      farms: const [Farm(id: 'farm-1', name: 'Demo Farm')],
      selectedFarm: const Farm(id: 'farm-1', name: 'Demo Farm'),
    );

    expect(RouteGuard.redirectFor(session, appHome.path), isNull);
  });

  test('password reset deep links are public and preserve token parameters', () {
    final resetLink = Uri.parse(
      'pigworldsmart://open/reset-password?token=reset-token&email=user%40example.com',
    );

    expect(resetLink.host, 'open');
    expect(resetLink.path, '/reset-password');
    expect(resetLink.queryParameters['token'], 'reset-token');
    expect(resetLink.queryParameters['email'], 'user@example.com');
    expect(RouteGuard.isPublic(resetLink.path), isTrue);
    expect(RouteGuard.redirectFor(null, resetLink.path), isNull);
  });

  test(
    'logged-in users without a selected farm are sent to farm selection',
    () {
      final session = Session(
        accessToken: 'token',
        refreshToken: 'refresh',
        user: const User(
          id: 'user-1',
          name: 'Test User',
          email: 'user@example.com',
          role: UserRole.farmOwner,
        ),
        farms: const [Farm(id: 'farm-1', name: 'Demo Farm')],
      );

      expect(RouteGuard.redirectFor(session, '/home'), '/farm-selection');
    },
  );

  test('farm managers and workers cannot access the subscription page', () {
    final session = Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      user: const User(
        id: 'user-1',
        name: 'Test User',
        email: 'user@example.com',
        role: UserRole.farmManager,
      ),
      farms: const [Farm(id: 'farm-1', name: 'Demo Farm')],
      selectedFarm: const Farm(id: 'farm-1', name: 'Demo Farm'),
    );

    expect(RouteGuard.redirectFor(session, '/subscription'), '/');
  });

  test('farm owners can access the subscription page', () {
    final session = Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      user: const User(
        id: 'user-1',
        name: 'Test User',
        email: 'user@example.com',
        role: UserRole.farmOwner,
      ),
      farms: const [Farm(id: 'farm-1', name: 'Demo Farm')],
      selectedFarm: const Farm(id: 'farm-1', name: 'Demo Farm'),
    );

    expect(RouteGuard.redirectFor(session, '/subscription'), null);
  });
}

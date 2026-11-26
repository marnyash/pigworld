import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:proj/features/auth/domain/entities/farm.dart';
import 'package:proj/features/auth/domain/entities/session.dart';
import 'package:proj/features/auth/domain/entities/user.dart';
import 'package:proj/features/auth/presentation/providers/auth_provider.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';
import 'package:proj/features/onboarding/presentation/pages/herd_setup_page.dart';
import 'package:proj/features/onboarding/presentation/pages/payment_method_page.dart';
import 'package:proj/security/authorization/roles.dart';

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AsyncValue<Session?> build() => AsyncData(_session);
}

void main() {
  const plan = {
    'code': 'starter',
    'name': 'Starter',
    'amount': 500,
    'currency': 'KES',
  };

  Session sessionWithEmptyHerd() {
    const farm = Farm(id: 'farm-1', name: 'Demo Farm');
    return const Session(
      accessToken: 'access',
      refreshToken: 'refresh',
      user: User(
        id: 'user-1',
        name: 'Test User',
        email: 'user@example.com',
        phone: '0746933820',
        role: UserRole.farmOwner,
      ),
      farms: [farm],
      selectedFarm: farm,
    );
  }

  GoRouter router() => GoRouter(
    initialLocation: '/payment-method',
    routes: [
      GoRoute(
        path: '/payment-method',
        builder: (context, state) =>
            const PaymentMethodPage(selectedPlan: plan),
      ),
      GoRoute(
        path: '/herd-setup',
        builder: (context, state) => HerdSetupPage.fromExtra(state.extra),
      ),
    ],
  );

  testWidgets('returns to required herd input before payment', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    var requestSent = false;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestSent = true;
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ),
    );
    final appRouter = router();
    addTearDown(appRouter.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          authProvider.overrideWith(
            () => _TestAuthNotifier(sessionWithEmptyHerd()),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();
    final currentSession = ProviderScope.containerOf(
      tester.element(find.byType(PaymentMethodPage)),
    ).read(authProvider).valueOrNull;
    expect(currentSession?.selectedFarm?.motherPigCount, 0);
    await tester.ensureVisible(find.text('Proceed'));
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();

    expect(find.byType(HerdSetupPage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mother-pig-count-field')),
      findsOneWidget,
    );
    expect(requestSent, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves herd count and returns to the selected payment plan', (
    tester,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    var patchData = <String, dynamic>{};
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method != 'PATCH' || options.path != '/farms/farm-1') {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
            return;
          }
          patchData = Map<String, dynamic>.from(options.data as Map);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {
                  'id': 'farm-1',
                  'name': 'Demo Farm',
                  'mother_pig_count': 6,
                  'piglet_groups': [],
                },
              },
            ),
          );
        },
      ),
    );
    final appRouter = router();
    addTearDown(appRouter.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          authProvider.overrideWith(
            () => _TestAuthNotifier(sessionWithEmptyHerd()),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Proceed'));
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('mother-pig-count-field')),
      '6',
    );
    await tester.ensureVisible(find.text('Save and return to payment'));
    await tester.tap(find.text('Save and return to payment'));
    await tester.pumpAndSettle();

    expect(patchData, {'mother_pig_count': 6});
    expect(find.text('Your selected plan: Starter'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PaymentMethodPage)),
    );
    expect(
      container.read(authProvider).valueOrNull?.selectedFarm?.motherPigCount,
      6,
    );
    expect(tester.takeException(), isNull);
  });
}

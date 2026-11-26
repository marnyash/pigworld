import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:proj/app/routes/app_routes.dart';
import 'package:proj/features/auth/domain/repositories/auth_repository.dart';
import 'package:proj/features/auth/domain/usecases/forgot_password.dart';
import 'package:proj/features/auth/domain/usecases/verify_password_reset_code.dart';
import 'package:proj/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('verifies the emailed code before opening password reset', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final router = GoRouter(
      initialLocation: AppRoutes.forgotPassword,
      routes: [
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) => Scaffold(
            body: Text(
              'reset:${state.uri.queryParameters['email']}:'
              '${state.uri.queryParameters['token']}',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          forgotPasswordUseCaseProvider.overrideWithValue(
            ForgotPassword(repository),
          ),
          verifyPasswordResetCodeUseCaseProvider.overrideWithValue(
            VerifyPasswordResetCode(repository),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('Send reset code'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.tap(find.text('Send reset code'));
    await tester.pumpAndSettle();

    expect(repository.requestedEmail, 'user@example.com');
    expect(find.text('Verify code'), findsOneWidget);
    expect(find.textContaining('No reset link is sent.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Verify code'));
    await tester.pumpAndSettle();

    expect(repository.verifiedEmail, 'user@example.com');
    expect(repository.verifiedCode, '123456');
    expect(find.text('reset:user@example.com:123456'), findsOneWidget);

    router.dispose();
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? requestedEmail;
  String? verifiedEmail;
  String? verifiedCode;

  @override
  Future<void> forgotPassword(String email) async {
    requestedEmail = email;
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    verifiedEmail = email;
    verifiedCode = code;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

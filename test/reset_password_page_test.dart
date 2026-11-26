import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:proj/app/routes/app_routes.dart';
import 'package:proj/features/auth/domain/entities/login_challenge.dart';
import 'package:proj/features/auth/domain/repositories/auth_repository.dart';
import 'package:proj/features/auth/domain/usecases/login.dart';
import 'package:proj/features/auth/domain/usecases/reset_password.dart';
import 'package:proj/features/auth/presentation/pages/reset_password_page.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('resets the password and starts sign-in OTP verification', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final router = GoRouter(
      initialLocation:
          '${AppRoutes.resetPassword}?token=reset-token&email=user%40example.com',
      routes: [
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (context, state) => ResetPasswordPage(
            token: state.uri.queryParameters['token'] ?? '',
            email: state.uri.queryParameters['email'] ?? '',
          ),
        ),
        GoRoute(
          path: AppRoutes.otpVerification,
          builder: (context, state) => Scaffold(
            body: Text(
              'challenge:${state.uri.queryParameters['challengeId']} '
              'destination:${state.uri.queryParameters['destination']}',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resetPasswordUseCaseProvider.overrideWithValue(
            ResetPassword(repository),
          ),
          loginUseCaseProvider.overrideWithValue(Login(repository)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .autofillHints,
      const [AutofillHints.newPassword],
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'new-password-123',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'new-password-123',
    );
    await tester.tap(find.text('Save new password'));
    await tester.pumpAndSettle();

    expect(repository.resetToken, 'reset-token');
    expect(repository.resetEmail, 'user@example.com');
    expect(repository.resetPasswordValue, 'new-password-123');
    expect(repository.loginEmail, 'user@example.com');
    expect(repository.loginPassword, 'new-password-123');
    expect(
      find.text('challenge:challenge-1 destination:user@example.com'),
      findsOneWidget,
    );

    router.dispose();
  });
}

class _FakeAuthRepository implements AuthRepository {
  String? resetToken;
  String? resetEmail;
  String? resetPasswordValue;
  String? loginEmail;
  String? loginPassword;

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    resetToken = token;
    resetEmail = email;
    resetPasswordValue = password;
  }

  @override
  Future<LoginChallenge> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    loginEmail = email;
    loginPassword = password;
    return const LoginChallenge(
      id: 'challenge-1',
      destination: 'user@example.com',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

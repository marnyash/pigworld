import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/auth/presentation/pages/login_page.dart';
import 'package:proj/features/auth/presentation/pages/otp_verification_page.dart';

void main() {
  testWidgets(
    'login page stays password-first and does not offer OTP sign-in',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginPage())),
      );

      expect(find.text('Use OTP'), findsNothing);
      expect(find.text('Sign in'), findsOneWidget);
    },
  );

  testWidgets('login requires agreement before enabling sign-in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    final signIn = find.widgetWithText(FilledButton, 'Sign in');
    expect(tester.widget<FilledButton>(signIn).onPressed, isNull);
    expect(find.text('User Agreement'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login-agreement-checkbox')));
    await tester.pump();

    expect(tester.widget<FilledButton>(signIn).onPressed, isNotNull);
  });

  testWidgets(
    'otp verification page asks for the code sent to the registered email',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpVerificationPage(
              challengeId: 'challenge-test',
              destination: 'u***@pigworld.com',
              rememberMe: false,
            ),
          ),
        ),
      );

      expect(find.text('OTP verification'), findsOneWidget);
      expect(find.textContaining('u***@pigworld.com'), findsOneWidget);
      expect(find.text('Verify and sign in'), findsOneWidget);
    },
  );
}

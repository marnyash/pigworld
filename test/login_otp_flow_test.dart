import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/auth/presentation/pages/login_page.dart';
import 'package:proj/features/auth/presentation/pages/otp_verification_page.dart';

void main() {
  testWidgets('login page stays password-first and does not offer OTP sign-in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Use OTP'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('otp verification page asks for the code sent to the registered email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpVerificationPage(email: 'user@pigworld.com'),
      ),
    );

    expect(find.text('OTP verification'), findsOneWidget);
    expect(find.textContaining('user@pigworld.com'), findsOneWidget);
    expect(find.text('Verify OTP'), findsOneWidget);
  });
}

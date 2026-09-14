import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/onboarding/presentation/pages/payment_method_page.dart';

void main() {
  testWidgets('shows payment method options for the recommended plan', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentMethodPage(
          selectedPlan: {
            'name': 'Growth',
            'amount': 2500,
            'currency': 'KES',
            'description': 'For growing teams and herds.',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('How would you like to pay?'), findsOneWidget);
    expect(find.text('M-Pesa'), findsOneWidget);
    expect(find.text('Airtel Money'), findsOneWidget);
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);
  });
}

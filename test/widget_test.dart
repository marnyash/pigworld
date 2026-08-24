// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proj/main.dart';

void main() {
  testWidgets('launches through onboarding and authentication', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    expect(find.text('PIG WORLD SMART'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2201));
    await tester.pump();
    expect(find.text('Choose your language'), findsOneWidget);

    final continueButton = find.ancestor(
      of: find.text('Continue'),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Select your country'), findsOneWidget);

    await tester.tap(find.byWidgetPredicate((widget) => widget is RadioListTile<String> && widget.value == 'Kenya'));
    await tester.pump();
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Choose your account type'), findsOneWidget);

    await tester.tap(find.text('Farm owner'));
    await tester.tap(find.text('Farm manager'));
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'manager@pigworld.farm');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Where are we working today?'), findsOneWidget);

    await tester.tap(find.text('Green Valley Farm'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Herd'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

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
  testWidgets('launches through auth and farm selection', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('PIG WORLD'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 901));
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'manager@pigworld.farm');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Where are we working today?'), findsOneWidget);

    await tester.tap(find.text('Green Valley Farm'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Herd'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

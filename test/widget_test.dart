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
  testWidgets('launches through onboarding and authentication', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    expect(find.text('PIG WORLD SMART'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2201));
    await tester.pump();
    expect(find.text('Choose your language'), findsOneWidget);

    expect(find.text('Search languages'), findsOneWidget);
  });
}

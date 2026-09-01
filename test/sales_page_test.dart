import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/sales/presentation/pages/sales_page.dart';

void main() {
  testWidgets('sales page renders the farm sales dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SalesPage()));

    expect(find.text('Sales'), findsAtLeastNWidgets(1));
    expect(find.text('Sales Overview'), findsOneWidget);
    expect(find.text("Today's Sales"), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

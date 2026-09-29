import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/tasks/presentation/pages/tasks_page.dart';
import 'package:proj/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('tasks page renders the farm task dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TasksPage(),
      ),
    );

    expect(find.text('Farm tasks'), findsOneWidget);
    expect(find.text('Due today'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

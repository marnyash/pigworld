import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/features/herd/presentation/pages/herd_page.dart';
import 'package:proj/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('herd page shows pregnant and vaccinated status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HerdPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Herd status'), findsOneWidget);
    expect(find.text('Pregnant'), findsOneWidget);
    expect(find.text('Vaccinated'), findsOneWidget);
  });
}

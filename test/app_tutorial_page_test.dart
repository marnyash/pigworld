import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:proj/app/routes/app_routes.dart';
import 'package:proj/features/onboarding/presentation/pages/app_tutorial_page.dart';

void main() {
  testWidgets('farm quest teaches key features before account setup', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.appTutorial,
      routes: [
        GoRoute(
          path: AppRoutes.appTutorial,
          builder: (context, state) => const AppTutorialPage(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) =>
              const Scaffold(body: Text('Language setup')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Build your herd'), findsOneWidget);
    expect(find.text('MISSION 1 OF 4'), findsOneWidget);
    expect(find.text('Skip tour'), findsOneWidget);

    for (final title in [
      'Keep every pig healthy',
      'Make daily care a routine',
      'Watch your farm grow',
    ]) {
      await tester.tap(find.text('Next mission'));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    }

    await tester.tap(find.text('Start your journey'));
    await tester.pumpAndSettle();
    expect(find.text('Language setup'), findsOneWidget);
  });

  testWidgets('tour can be skipped to onboarding language setup', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.appTutorial,
      routes: [
        GoRoute(
          path: AppRoutes.appTutorial,
          builder: (context, state) => const AppTutorialPage(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) =>
              const Scaffold(body: Text('Language setup')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip tour'));
    await tester.pumpAndSettle();

    expect(find.text('Language setup'), findsOneWidget);
  });
}

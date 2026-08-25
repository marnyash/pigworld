import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import '../shared/providers/theme_provider.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AppRoot());
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pig World Smart App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false,
      locale: Locale(ref.watch(onboardingProvider).languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('sw'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        Locale('pt'),
        Locale('ar'),
        Locale('zh'),
        Locale('hi'),
        Locale('ru'),
        Locale('ja'),
        Locale('ko'),
        Locale('tr'),
        Locale('it'),
        Locale('nl'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: AppRouter.router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

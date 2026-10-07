import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/generated/app_localizations.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import '../shared/providers/theme_provider.dart';
import '../shared/providers/connectivity_provider.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import '../features/notifications/data/notifications_api.dart';
import '../features/notifications/presentation/providers/notifications_provider.dart';
import '../features/notifications/data/push_notification_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _AppRoot());
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  late final PushNotificationService _pushNotifications;
  late final ProviderSubscription _authSubscription;

  @override
  void initState() {
    super.initState();
    _pushNotifications = PushNotificationService(ref.read(dioProvider));
    _authSubscription = ref.listenManual(authProvider, (previous, next) {
      if (next.valueOrNull != null) {
        unawaited(
          _pushNotifications.registerDevice().catchError((error) {
            debugPrint('Push notification setup failed: $error');
          }),
        );
      } else if (previous?.valueOrNull != null) {
        unawaited(
          _pushNotifications.unregisterDevice().catchError((error) {
            debugPrint('Push-token removal failed: $error');
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false,
      locale: Locale(ref.watch(appLanguageProvider)),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: AppRouter.router,
      builder: (context, child) => Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => _OfflineBannerOverlay(child: child),
          ),
        ],
      ),
    );
  }
}

class _OfflineBannerOverlay extends ConsumerWidget {
  const _OfflineBannerOverlay({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline =
        ref.watch(connectivityProvider).valueOrNull ==
        ConnectivityStatus.offline;
    return Column(
      children: [
        if (isOffline)
          Material(
            color: Theme.of(context).colorScheme.error,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noInternetConnection,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const _NotificationBanner(),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    );
  }
}

class _NotificationBanner extends ConsumerStatefulWidget {
  const _NotificationBanner();

  @override
  ConsumerState<_NotificationBanner> createState() =>
      _NotificationBannerState();
}

class _NotificationBannerState extends ConsumerState<_NotificationBanner> {
  String? _dismissedNotificationId;

  @override
  Widget build(BuildContext context) {
    final notification = ref
        .watch(notificationsProvider)
        .valueOrNull
        ?.firstWhereOrNull((item) => !item.isRead);

    if (notification == null || notification.id == _dismissedNotificationId) {
      return const SizedBox.shrink();
    }

    final color = switch (notification.severity) {
      'danger' => Colors.red,
      'warning' => Colors.orange,
      'success' => Colors.green,
      _ => Theme.of(context).colorScheme.primary,
    };

    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: () => _openNotification(notification),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppLocalizations.of(
                    context,
                  )!.dismissNotificationBanner,
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(
                    () => _dismissedNotificationId = notification.id,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNotification(FarmNotification notification) async {
    try {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
    } finally {
      if (mounted) context.push(AppRoutes.notifications);
    }
  }
}

extension on Iterable<FarmNotification> {
  FarmNotification? firstWhereOrNull(bool Function(FarmNotification) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
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

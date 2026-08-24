import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      final session = ref.read(authProvider).valueOrNull;
      if (session?.selectedFarm != null) {
        context.go(AppRoutes.home);
        return;
      }
        final isMobile = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
        if (isMobile) unawaited(_requestRuntimePermissions());
        if (mounted) context.go(AppRoutes.language);
    });
  }

  Future<void> _requestRuntimePermissions() async {
    final isMobile = !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    if (!isMobile) return;
    try {
      await [Permission.notification, Permission.location].request();
    } on Exception {
      // Unsupported or denied permissions must not block first launch.
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                child: Icon(Icons.pets, size: 52, color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/images/logo.jpeg', width: 120, height: 120),
              const SizedBox(height: 20),
              Text('PIG WORLD SMART', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Smart Pig Farm Management', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Version 1.0.0', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 32),
              Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../domain/entities/session.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;
  final bool _showMark = true;

  @override
  void initState() {
    super.initState();
    // Let the router finish mounting before replacing the initial route.
    // Navigating directly from initState can leave the Router with no page on
    // some cold starts (most noticeably after the native splash disappears).
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    if (_navigated || !mounted) return;
    Session? session;
    try {
      session = await ref.read(sessionRestoreProvider.future);
    } catch (_) {
      // A corrupt/unavailable persisted session must not strand the user on a
      // blank startup screen. Continue as signed out instead.
      ref.read(authProvider.notifier).clearSession();
    }
    if (!mounted) return;
    if (session != null) {
      _navigated = true;
      context.go(
        session.selectedFarm != null ? AppRoutes.home : AppRoutes.farmSelection,
      );
      return;
    }
    bool onboardingCompleted;
    try {
      onboardingCompleted = await ref.read(onboardingCompletedProvider.future);
    } catch (_) {
      // Login is the safe fallback if the onboarding preference is unreadable.
      onboardingCompleted = true;
    }
    if (!mounted) return;
    _navigated = true;
    context.go(onboardingCompleted ? AppRoutes.login : AppRoutes.language);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.primary,
    body: Center(
      child: AnimatedOpacity(
        opacity: _showMark ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets,
                size: 52,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/logo.jpeg', width: 120, height: 120),
            const SizedBox(height: 20),
            Text(
              'PIG WORLD SMART',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Pig Farm Management',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    ),
  );
}

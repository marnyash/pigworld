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
    backgroundColor: Colors.white,
    body: Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Image.asset(
          'assets/images/logo.jpeg',
          width: constraints.maxWidth * 0.84,
          height: constraints.maxHeight * 0.84,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

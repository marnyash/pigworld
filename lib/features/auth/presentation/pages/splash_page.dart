import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
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
    _navigate();
  }

  Future<void> _navigate() async {
    if (_navigated || !mounted) return;
    final session = await ref.read(sessionRestoreProvider.future);
    if (!mounted) return;
    if (session != null) {
      _navigated = true;
      context.go(
        session.selectedFarm != null ? AppRoutes.home : AppRoutes.farmSelection,
      );
      return;
    }
    final onboardingCompleted = await ref.read(
      onboardingCompletedProvider.future,
    );
    if (!mounted) return;
    _navigated = true;
    context.go(onboardingCompleted ? AppRoutes.login : AppRoutes.language);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
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
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Smart Pig Farm Management',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text('Version 1.0.0', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 32),
          Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    ),
  );
}

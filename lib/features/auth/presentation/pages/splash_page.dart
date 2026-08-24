import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final session = ref.read(authProvider).valueOrNull;
      context.go(session?.selectedFarm == null ? AppRoutes.login : AppRoutes.home);
    });
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
              Text('PIG WORLD', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Smart farm management', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  String _plan = 'starter';
  bool _saving = false;

  static const _plans = [
    ('starter', 'Starter', 'For small farms getting started.', 'Up to 50 pigs'),
    ('growth', 'Growth', 'For growing teams and herds.', 'Up to 250 pigs'),
    (
      'enterprise',
      'Enterprise',
      'For large or multi-farm operations.',
      'Unlimited pigs',
    ),
  ];

  Future<void> _continue() async {
    final farmId = ref.read(authProvider).valueOrNull?.selectedFarm?.id;
    if (farmId == null) {
      context.go(AppRoutes.home);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(dioProvider)
          .patch('/farms/$farmId/subscription', data: {'plan': _plan});
      if (mounted) context.go(AppRoutes.home);
    } on DioException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save subscription: $error')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose subscription')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Choose a plan for your farm',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('You can change your plan later from farm settings.'),
        const SizedBox(height: 24),
        ..._plans.map(
          (plan) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              value: plan.$1,
              // ignore: deprecated_member_use
              groupValue: _plan,
              // ignore: deprecated_member_use
              onChanged: (value) => setState(() => _plan = value ?? _plan),
              title: Text(plan.$2),
              subtitle: Text('${plan.$3}\n${plan.$4}'),
              isThreeLine: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _continue,
          child: _saving
              ? const CircularProgressIndicator()
              : const Text('Continue to dashboard'),
        ),
      ],
    ),
  );
}

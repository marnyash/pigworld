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
  String? _plan;
  List<Map<String, dynamic>> _plans = [];
  bool _loadingPlans = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final response = await ref.read(dioProvider).get('/subscription-plans');
      final plans = List<Map<String, dynamic>>.from(
        (response.data['data'] as List<dynamic>? ?? []).map(
          (plan) => Map<String, dynamic>.from(plan as Map),
        ),
      );
      if (mounted) {
        setState(() {
          _plans = plans;
          _plan = plans.isEmpty ? null : plans.first['code'] as String;
          _loadingPlans = false;
        });
      }
    } on DioException catch (error) {
      if (mounted) {
        setState(() => _loadingPlans = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load subscriptions: $error')),
        );
      }
    }
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save subscription: $error')),
        );
      }
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
        if (_loadingPlans)
          const Center(child: CircularProgressIndicator())
        else if (_plans.isEmpty)
          const Text('No subscription plans are available yet.')
        else
          ..._plans.map(
            (plan) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                value: plan['code'] as String,
                // ignore: deprecated_member_use
                groupValue: _plan,
                // ignore: deprecated_member_use
                onChanged: (value) => setState(() => _plan = value),
                title: Text(
                  '${plan['name']} - ${plan['amount']} ${plan['currency']}',
                ),
                subtitle: Text(
                  '${plan['description'] ?? ''}\n${plan['pig_limit'] == null ? 'Unlimited pigs' : 'Up to ${plan['pig_limit']} pigs'}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving || _loadingPlans || _plan == null
              ? null
              : _continue,
          child: _saving
              ? const CircularProgressIndicator()
              : const Text('Continue to dashboard'),
        ),
      ],
    ),
  );
}

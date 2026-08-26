import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_scaffold.dart';

class HerdSetupPage extends ConsumerStatefulWidget {
  const HerdSetupPage({super.key});

  @override
  ConsumerState<HerdSetupPage> createState() => _HerdSetupPageState();
}

class _HerdSetupPageState extends ConsumerState<HerdSetupPage> {
  final _motherPigs = TextEditingController();
  final _pregnantPigs = TextEditingController();
  final _pigletCount = TextEditingController();
  final _pigletAge = TextEditingController();
  final _groups = <PigletGroup>[];
  int _step = 0;

  @override
  void dispose() {
    _motherPigs.dispose();
    _pregnantPigs.dispose();
    _pigletCount.dispose();
    _pigletAge.dispose();
    super.dispose();
  }

  int? _number(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim());
    return value != null && value >= 0 ? value : null;
  }

  void _next() {
    if (_step == 0 && _number(_motherPigs) == null) {
      _message('Enter how many mother pigs you have.');
      return;
    }
    if (_step == 1 && _pigletCount.text.trim().isNotEmpty) {
      final count = _number(_pigletCount);
      final age = _number(_pigletAge);
      if (count == null || age == null) {
        _message('Enter a piglet count and age in months.');
        return;
      }
      _groups.add(PigletGroup(count: count, ageMonths: age));
      _pigletCount.clear();
      _pigletAge.clear();
    }
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    final pregnant = _pregnantPigs.text.trim().isEmpty
        ? null
        : _number(_pregnantPigs);
    if (_pregnantPigs.text.trim().isNotEmpty && pregnant == null) {
      _message('Enter a valid number of pregnant pigs, or leave it blank.');
      return;
    }
    ref
        .read(onboardingProvider.notifier)
        .setHerdSetup(
          motherPigCount: _number(_motherPigs)!,
          pigletGroups: List.unmodifiable(_groups),
          pregnantPigCount: pregnant,
        );
    context.go(AppRoutes.createAccount);
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => OnboardingScaffold(
    progress: (_step + 1) / 3,
    body: OnboardingEntry(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          OnboardingHeader(
            eyebrow: 'Farm setup • Step ${_step + 1} of 3',
            title: _step == 0
                ? 'Start with your herd'
                : _step == 1
                ? 'Track your piglets'
                : 'Add pregnancy records',
            subtitle: _step == 0
                ? 'A quick snapshot helps Pig World Smart personalize your dashboard.'
                : _step == 1
                ? 'Group piglets by age. You can add these details later.'
                : 'This optional detail helps keep your breeding picture current.',
          ),
          const SizedBox(height: 28),
          if (_step == 0) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _motherPigs,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of mother pigs',
                prefixIcon: Icon(Icons.pets_outlined),
              ),
            ),
          ] else if (_step == 1) ...[
            const SizedBox(height: 4),
            for (final group in _groups)
              ListTile(
                leading: const Icon(Icons.pets_outlined),
                title: Text('${group.count} piglets'),
                subtitle: Text('${group.ageMonths} months old'),
              ),
            TextField(
              controller: _pigletCount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Piglet count'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pigletAge,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age in months'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                final count = _number(_pigletCount);
                final age = _number(_pigletAge);
                if (count == null || age == null) {
                  _message('Enter a piglet count and age in months.');
                  return;
                }
                setState(() {
                  _groups.add(PigletGroup(count: count, ageMonths: age));
                  _pigletCount.clear();
                  _pigletAge.clear();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add another age group'),
            ),
          ] else ...[
            const SizedBox(height: 4),
            TextField(
              controller: _pregnantPigs,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of pregnant pigs (optional)',
              ),
            ),
          ],
        ],
      ),
    ),
    actions: Row(
      children: [
        TextButton(
          onPressed: _step == 0
              ? () => context.go(AppRoutes.accountType)
              : () => setState(() => _step--),
          child: const Text('Back'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: _next,
          child: Text(_step == 2 ? 'Continue to account' : 'Continue'),
        ),
      ],
    ),
  );
}

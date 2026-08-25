import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../providers/onboarding_provider.dart';

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

  int? _number(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Farm setup ${_step + 1} of 3')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          LinearProgressIndicator(value: (_step + 1) / 3),
          const SizedBox(height: 24),
          if (_step == 0) ...[
            Text(
              'Mother pigs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'How many adult mother pigs are currently on your farm?',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _motherPigs,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of mother pigs',
              ),
            ),
          ] else if (_step == 1) ...[
            Text(
              'Piglets by age',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add each group of piglets with its current age. You can skip this section.',
            ),
            const SizedBox(height: 20),
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
            Text(
              'Pregnancy records',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Do you have mother pigs that are pregnant? This is optional and can be added later.',
            ),
            const SizedBox(height: 24),
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
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
      ),
    ),
  );
}

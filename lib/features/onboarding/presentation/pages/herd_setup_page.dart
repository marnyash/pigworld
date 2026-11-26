import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/models/farm_model.dart';
import '../../../auth/domain/entities/session.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_scaffold.dart';

class HerdSetupPage extends ConsumerStatefulWidget {
  const HerdSetupPage({super.key, this.selectedPlan});

  final Map<String, dynamic>? selectedPlan;

  factory HerdSetupPage.fromExtra(Object? extra) {
    final payload = extra is Map
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    final plan = payload['selected_plan'];
    return HerdSetupPage(
      selectedPlan: plan is Map ? Map<String, dynamic>.from(plan) : null,
    );
  }

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
  bool _isSaving = false;

  bool get _isPaymentResume => widget.selectedPlan != null;

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

  bool _addGroup() {
    final count = _number(_pigletCount);
    final age = _number(_pigletAge);
    if (count == null || age == null) {
      _message('Enter a piglet count and age in months.');
      return false;
    }
    setState(() {
      _groups.add(PigletGroup(count: count, ageMonths: age));
      _pigletCount.clear();
      _pigletAge.clear();
    });
    return true;
  }

  void _next() {
    if (_step == 0 && _number(_motherPigs) == null) {
      _message('Enter how many mother pigs you have.');
      return;
    }
    if (_isPaymentResume && _step == 0) {
      final count = _number(_motherPigs);
      if (count == null || count < 1) {
        _message('Enter at least one mother pig to continue to payment.');
        return;
      }
      _saveRequiredHerdCount(count);
      return;
    }
    if (_step == 1 &&
        (_pigletCount.text.trim().isNotEmpty ||
            _pigletAge.text.trim().isNotEmpty) &&
        !_addGroup()) {
      return;
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

  Future<void> _saveRequiredHerdCount(int count) async {
    final session = ref.read(authProvider).valueOrNull;
    final farm =
        session?.selectedFarm ??
        (session?.farms.isNotEmpty ?? false ? session!.farms.first : null);
    if (session == null || farm == null || farm.id.isEmpty) {
      _message('Select a farm before saving herd details.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await ref
          .read(dioProvider)
          .patch('/farms/${farm.id}', data: {'mother_pig_count': count});
      final responseData = response.data;
      final farmData = responseData is Map ? responseData['data'] : null;
      if (farmData is! Map) {
        throw const FormatException(
          'The saved farm details were not returned.',
        );
      }

      final updatedFarm = FarmModel.fromJson(
        Map<String, dynamic>.from(farmData),
      );
      final updatedFarms = session.farms
          .map((item) => item.id == updatedFarm.id ? updatedFarm : item)
          .toList(growable: false);
      ref
          .read(authProvider.notifier)
          .setSession(
            Session(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken,
              user: session.user,
              farms: updatedFarms,
              selectedFarm: session.selectedFarm?.id == updatedFarm.id
                  ? updatedFarm
                  : session.selectedFarm,
            ),
          );
      if (mounted) {
        context.go(
          AppRoutes.paymentMethod,
          extra: {'selected_plan': widget.selectedPlan},
        );
      }
    } catch (error) {
      if (mounted) _message('Could not save herd details: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => OnboardingScaffold(
    topAction: _isPaymentResume
        ? const SizedBox.shrink()
        : TextButton(
            onPressed: () async {
              await ref.read(onboardingStorageProvider).markCompleted();
              if (!context.mounted) return;
              context.go(AppRoutes.createAccount);
            },
            child: const Text('Skip'),
          ),
    progress: (_step + 1) / 3,
    body: OnboardingEntry(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          OnboardingHeader(
            eyebrow: _isPaymentResume
                ? 'Required before payment'
                : 'Step 4 of 4 · Farm setup • ${_step + 1} of 3',
            title: _step == 0
                ? 'Start with your herd'
                : _step == 1
                ? 'Track your piglets'
                : 'Add pregnancy records',
            subtitle: _step == 0
                ? 'A quick snapshot helps Pig World Smart personalize your dashboard.'
                : _step == 1
                ? 'Group piglets by age. You can add these details later.'
                : 'This optional detail helps keep your insemination picture current.',
          ),
          const SizedBox(height: 28),
          if (_step == 0) ...[
            _SetupCard(
              icon: Icons.savings_outlined,
              iconColor: AppColors.pigPink,
              iconBackground: AppColors.secondaryContainer,
              title: 'Mother pigs',
              description: 'Add the sows currently in your herd.',
              child: TextField(
                key: const ValueKey('mother-pig-count-field'),
                controller: _motherPigs,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of mother pigs',
                  hintText: 'For example, 12',
                  suffixText: 'pigs',
                ),
              ),
            ),
          ] else if (_step == 1) ...[
            if (_groups.isNotEmpty) ...[
              Text(
                'Added age groups',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              for (final (index, group) in _groups.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: ListTile(
                      leading: const _IconBadge(
                        icon: Icons.pets_outlined,
                        color: AppColors.warmGold,
                        background: AppColors.warningContainer,
                      ),
                      title: Text('${group.count} piglets'),
                      subtitle: Text('${group.ageMonths} months old'),
                      trailing: IconButton(
                        tooltip: 'Remove this age group',
                        onPressed: () =>
                            setState(() => _groups.removeAt(index)),
                        icon: const Icon(Icons.close, color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            _SetupCard(
              icon: Icons.pets_outlined,
              iconColor: AppColors.warmGold,
              iconBackground: AppColors.warningContainer,
              title: 'Piglet age group',
              description:
                  'Add a group whenever the piglets are a different age.',
              child: Column(
                children: [
                  TextField(
                    controller: _pigletCount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Piglet count',
                      hintText: 'For example, 8',
                      suffixText: 'piglets',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pigletAge,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'For example, 3',
                      suffixText: 'months',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addGroup,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add age group'),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _SetupCard(
              icon: Icons.favorite_outline,
              iconColor: AppColors.primaryGreen,
              iconBackground: AppColors.primaryContainer,
              title: 'Pregnancy records',
              description:
                  'This is optional and helps you plan upcoming litters.',
              child: TextField(
                controller: _pregnantPigs,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of pregnant pigs',
                  hintText: 'Leave blank if none',
                  suffixText: 'pigs',
                ),
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
              ? _isPaymentResume
                    ? () => context.go(
                        AppRoutes.paymentMethod,
                        extra: {'selected_plan': widget.selectedPlan},
                      )
                    : () => context.go(AppRoutes.accountType)
              : () => setState(() => _step--),
          child: const Text('Back'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: _isSaving ? null : _next,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _isPaymentResume
                      ? 'Save and return to payment'
                      : _step == 2
                      ? 'Continue to account'
                      : 'Continue',
                ),
        ),
      ],
    ),
  );
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.outline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconBadge(
              icon: icon,
              color: iconColor,
              background: iconBackground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: Icon(icon, color: color),
  );
}

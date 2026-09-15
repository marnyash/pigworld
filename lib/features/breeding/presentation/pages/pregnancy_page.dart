import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../herd/presentation/providers/herd_provider.dart';
import '../providers/pregnancy_provider.dart';

class PregnancyPage extends ConsumerWidget {
  const PregnancyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnancies = ref.watch(pregnancyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pregnancy tracking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPregnancy(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add pregnancy'),
      ),
      body: pregnancies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: '$error',
          onRetry: () => ref.invalidate(pregnancyProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No pregnancy records yet. Add a mating record to begin.',
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(pregnancyProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _Summary(items: items),
                const SizedBox(height: 16),
                ...items.map((item) => _PregnancyCard(pregnancy: item)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddPregnancy(BuildContext context, WidgetRef ref) async {
    final animals = ref.read(herdProvider).valueOrNull ?? const [];
    final sows = animals.where((animal) => animal.type == 'sow').toList();
    if (sows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a sow in Herd before recording pregnancy.'),
        ),
      );
      return;
    }
    var sowId = sows.first.id;
    var matingDate = DateTime.now();
    var status = 'suspected';
    final litterController = TextEditingController();
    final notesController = TextEditingController();
    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Record pregnancy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: sowId,
                    decoration: const InputDecoration(labelText: 'Sow'),
                    items: sows
                        .map(
                          (sow) => DropdownMenuItem(
                            value: sow.id,
                            child: Text(sow.tag),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setSheetState(() => sowId = value ?? sowId),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mating date'),
                    subtitle: Text(_date(matingDate)),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: matingDate,
                      );
                      if (picked != null) {
                        setSheetState(() => matingDate = picked);
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'suspected',
                        child: Text('Suspected'),
                      ),
                      DropdownMenuItem(
                        value: 'confirmed',
                        child: Text('Confirmed'),
                      ),
                      DropdownMenuItem(
                        value: 'high_risk',
                        child: Text('High risk'),
                      ),
                    ],
                    onChanged: (value) =>
                        setSheetState(() => status = value ?? status),
                  ),
                  TextField(
                    controller: litterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Expected litter size',
                    ),
                  ),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: Text(
                      'Save (due ${_date(matingDate.add(const Duration(days: 114)))})',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (result != true || !context.mounted) return;
      await ref
          .read(pregnancyProvider.notifier)
          .create(
            sowId: sowId,
            matingDate: matingDate,
            status: status,
            expectedLitterSize: int.tryParse(litterController.text),
            notes: notesController.text,
          );
    } finally {
      litterController.dispose();
      notesController.dispose();
    }
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.items});
  final List items;

  @override
  Widget build(BuildContext context) {
    final active = items
        .where((item) => item.status != 'farrowed' && item.status != 'aborted')
        .length;
    final dueSoon = items.where((item) => item.isDueSoon).length;
    final overdue = items.where((item) => item.isOverdue).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Metric(label: 'Active', value: '$active'),
            _Metric(
              label: 'Due soon',
              value: '$dueSoon',
              color: AppColors.warmGold,
            ),
            _Metric(
              label: 'Overdue',
              value: '$overdue',
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(color: color),
      ),
      Text(label),
    ],
  );
}

class _PregnancyCard extends StatelessWidget {
  const _PregnancyCard({required this.pregnancy});
  final dynamic pregnancy;
  @override
  Widget build(BuildContext context) {
    final color = pregnancy.isOverdue
        ? AppColors.danger
        : pregnancy.isDueSoon
        ? AppColors.warmGold
        : AppColors.primaryGreen;
    final dueText = pregnancy.isOverdue
        ? '${-pregnancy.daysUntilFarrowing} days overdue'
        : '${pregnancy.daysUntilFarrowing} days until farrowing';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .14),
          child: Icon(Icons.favorite_outline, color: color),
        ),
        title: Text(pregnancy.sowTag ?? 'Sow ${pregnancy.sowId}'),
        subtitle: Text(
          'Due ${_date(pregnancy.expectedFarrowingDate)} • $dueText',
        ),
        trailing: Text(_statusLabel(pregnancy.status)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String _statusLabel(String value) => value.replaceAll('_', ' ');

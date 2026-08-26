import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../domain/entities/animal.dart';
import '../providers/herd_provider.dart';

class HerdPage extends ConsumerWidget {
  const HerdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final herd = ref.watch(herdProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herd'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh herd',
            onPressed: () => ref.invalidate(herdProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSowDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add sow'),
      ),
      body: herd.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(herdProvider),
            icon: const Icon(Icons.refresh),
            label: Text('Could not load herd: $error'),
          ),
        ),
        data: (animals) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(herdProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.pagePadding,
              AppDimensions.pagePadding,
              96,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _HerdSummary(
                      label: 'Total animals',
                      value: '${animals.length}',
                      icon: Icons.pets_outlined,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: _HerdSummary(
                      label: 'Active',
                      value:
                          '${animals.where((animal) => animal.status == 'active').length}',
                      icon: Icons.favorite_border,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              Text(
                'Your animals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              if (animals.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 40,
                          color: AppColors.primaryGreen,
                        ),
                        SizedBox(height: 12),
                        Text('No animals recorded yet'),
                        SizedBox(height: 4),
                        Text(
                          'Add your first sow to start tracking the herd.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...animals.map(
                  (animal) => _AnimalCard(
                    animal: animal,
                    onEdit: () => _showEditAnimalDialog(context, ref, animal),
                    onArchive: () => _archiveAnimal(context, ref, animal),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSowDialog(BuildContext context, WidgetRef ref) async {
    final tagController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? birthDate;
    final formKey = GlobalKey<FormState>();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add sow'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tagController,
                    decoration: const InputDecoration(labelText: 'Tag'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter an animal tag.'
                        : null,
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1990),
                          lastDate: DateTime.now(),
                          initialDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => birthDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        birthDate == null
                            ? 'Add birth date'
                            : 'Born ${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  try {
                    await ref
                        .read(herdProvider.notifier)
                        .createSow(
                          tag: tagController.text.trim(),
                          birthDate: birthDate,
                          notes: notesController.text,
                        );
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not add sow: $error')),
                      );
                    }
                  }
                },
                child: const Text('Add sow'),
              ),
            ],
          ),
        ),
      );
    } finally {
      tagController.dispose();
      notesController.dispose();
    }
  }

  Future<void> _archiveAnimal(
    BuildContext context,
    WidgetRef ref,
    Animal animal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive animal?'),
        content: Text(
          'Mark ${animal.tag} as deceased and remove it from active herd tracking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(herdProvider.notifier).archiveAnimal(animal.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not archive animal: $error')),
        );
      }
    }
  }

  Future<void> _showEditAnimalDialog(
    BuildContext context,
    WidgetRef ref,
    Animal animal,
  ) async {
    final tagController = TextEditingController(text: animal.tag);
    final notesController = TextEditingController(text: animal.notes ?? '');
    String status = animal.status;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Edit ${animal.tag}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                decoration: const InputDecoration(labelText: 'Tag'),
              ),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'sold', child: Text('Sold')),
                  DropdownMenuItem(value: 'deceased', child: Text('Deceased')),
                ],
                onChanged: (value) => status = value ?? status,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (tagController.text.trim().isEmpty) return;
                try {
                  await ref
                      .read(herdProvider.notifier)
                      .updateAnimal(
                        animalId: animal.id,
                        tag: tagController.text,
                        status: status,
                        notes: notesController.text,
                      );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not update animal: $error'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      tagController.dispose();
      notesController.dispose();
    }
  }
}

class _HerdSummary extends StatelessWidget {
  const _HerdSummary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.onEdit,
    required this.onArchive,
  });
  final Animal animal;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final active = animal.status == 'active';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.pigPink.withValues(alpha: 0.25),
          child: const Icon(Icons.pets_outlined, color: AppColors.deepGreen),
        ),
        title: Text(animal.tag),
        subtitle: Text('${animal.type} · ${animal.sex}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(animal.status),
              side: BorderSide.none,
              backgroundColor: (active ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.14),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? onEdit() : onArchive(),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'archive', child: Text('Archive')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/herd_provider.dart';

class HerdPage extends ConsumerWidget {
  const HerdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final herd = ref.watch(herdProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herd'),
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
        data: (animals) => animals.isEmpty
            ? const Center(
                child: Text('No animals recorded yet. Add your first sow.'),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(herdProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: animals.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.pets_outlined),
                      ),
                      title: Text(animal.tag),
                      subtitle: Text('${animal.type} · ${animal.status}'),
                      trailing: animal.birthDate == null
                          ? null
                          : Text(
                              '${animal.birthDate!.day}/${animal.birthDate!.month}/${animal.birthDate!.year}',
                            ),
                    );
                  },
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
}

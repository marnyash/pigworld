import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/errors/error_handler.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_interaction.dart';
import '../providers/crm_provider.dart';
import '../providers/crm_providers.dart';

class CustomerDetailsPage extends ConsumerWidget {
  const CustomerDetailsPage({required this.customerId, super.key});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer details'),
        actions: [
          IconButton(
            tooltip: 'Delete customer',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addInteraction(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Log interaction'),
      ),
      body: customerAsync.when(
        data: (customer) => _CustomerDetailsBody(customer: customer),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            error is ApiException ? error.message : 'Unable to load customer.',
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete customer?'),
        content: const Text(
          'This will remove the customer and their interaction history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(deleteCustomerUseCaseProvider).call(customerId);
    ref.invalidate(customersProvider);
    if (context.mounted) context.pop();
  }

  Future<void> _addInteraction(BuildContext context, WidgetRef ref) async {
    var type = InteractionType.note;
    final notesController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log interaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<InteractionType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in InteractionType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;

    await ref
        .read(addInteractionUseCaseProvider)
        .call(
          customerId: customerId,
          type: type,
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
        );
    ref.invalidate(customerInteractionsProvider(customerId));
  }
}

class _CustomerDetailsBody extends ConsumerWidget {
  const _CustomerDetailsBody({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionsAsync = ref.watch(
      customerInteractionsProvider(customer.id),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        96,
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                Wrap(
                  spacing: AppDimensions.spacingSmall,
                  children: [
                    Chip(label: Text(customer.type.label)),
                    Chip(label: Text(customer.status.label)),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                if (customer.company != null && customer.company!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.business_outlined,
                    label: customer.company!,
                  ),
                if (customer.phone != null && customer.phone!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: customer.phone!,
                  ),
                if (customer.email != null && customer.email!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: customer.email!,
                  ),
                if (customer.address != null && customer.address!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: customer.address!,
                  ),
                if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(customer.notes!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text(
          'Interaction history',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        interactionsAsync.when(
          data: (interactions) {
            if (interactions.isEmpty) {
              return const Text('No interactions logged yet.');
            }
            return Column(
              children: [
                for (final interaction in interactions)
                  _InteractionTile(interaction: interaction),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(
            error is ApiException
                ? error.message
                : 'Unable to load interactions.',
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppDimensions.spacingSmall),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.text.withValues(alpha: 0.6)),
        const SizedBox(width: AppDimensions.spacingSmall),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

class _InteractionTile extends StatelessWidget {
  const _InteractionTile({required this.interaction});

  final CustomerInteraction interaction;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(_icon(interaction.type))),
      title: Text(interaction.type.label),
      subtitle: interaction.notes != null && interaction.notes!.isNotEmpty
          ? Text(interaction.notes!)
          : null,
      trailing: Text(
        '${interaction.occurredAt.month}/${interaction.occurredAt.day}',
      ),
    ),
  );

  IconData _icon(InteractionType type) => switch (type) {
    InteractionType.call => Icons.call_outlined,
    InteractionType.email => Icons.email_outlined,
    InteractionType.visit => Icons.home_outlined,
    InteractionType.meeting => Icons.groups_outlined,
    InteractionType.note => Icons.notes_outlined,
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../data/feed_api.dart';
import '../providers/feed_provider.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: 'Record usage',
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () => _showUsageDialog(context, ref, feed.valueOrNull),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStockDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add stock'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          96,
        ),
        children: [
          Text(
            'Feed overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Keep an eye on what is available for the next feeding cycle.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          feed.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                ),
                title: const Text('Could not load feed data'),
                subtitle: Text('$error'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(feedProvider),
                ),
              ),
            ),
            data: (snapshot) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total stock',
                        value: snapshot.totalQuantity.toStringAsFixed(1),
                        unit: 'bags',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Daily use',
                        value: snapshot.usage.isEmpty
                            ? '0.0'
                            : (snapshot.usage
                                          .take(7)
                                          .fold<double>(
                                            0,
                                            (total, item) =>
                                                total + item.quantity,
                                          ) /
                                      snapshot.usage.take(7).length)
                                  .toStringAsFixed(1),
                        unit: 'bags',
                        icon: Icons.trending_down_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock levels',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${snapshot.stock.length} items',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                if (snapshot.stock.isEmpty)
                  const Card(
                    child: ListTile(title: Text('No feed stock recorded yet.')),
                  )
                else
                  ...snapshot.stock.map((item) => _FeedTile(item: item)),
                const SizedBox(height: AppDimensions.spacingLarge),
                Text(
                  'Recent usage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                if (snapshot.usage.isEmpty)
                  const Card(
                    child: ListTile(title: Text('No feed usage recorded yet.')),
                  )
                else
                  Card(
                    child: Column(
                      children: snapshot.usage
                          .take(10)
                          .map(
                            (item) => ListTile(
                              leading: const Icon(Icons.outbox_outlined),
                              title: Text(item.feedName ?? 'Feed usage'),
                              subtitle: Text(
                                item.notes ??
                                    item.usedAt
                                        .toLocal()
                                        .toString()
                                        .split('.')
                                        .first,
                              ),
                              trailing: Text(
                                '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddStockDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add feed stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Feed name'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity (bags)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (nameController.text.trim().isEmpty || quantity <= 0) return;
                ref
                    .read(feedProvider.notifier)
                    .addStock(
                      name: nameController.text.trim(),
                      quantity: quantity.toDouble(),
                      unit: 'bags',
                    )
                    .then((_) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    })
                    .catchError((error) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('$error')));
                      }
                    });
              },
              child: const Text('Add stock'),
            ),
          ],
        ),
      );
    } finally {
      nameController.dispose();
      quantityController.dispose();
    }
  }

  Future<void> _showUsageDialog(
    BuildContext context,
    WidgetRef ref,
    FeedSnapshot? snapshot,
  ) async {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    String? stockId = snapshot == null || snapshot.stock.isEmpty
        ? null
        : snapshot.stock.first.id;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: stockId,
              items: [
                for (final item in snapshot?.stock ?? <FeedStock>[])
                  DropdownMenuItem(value: item.id, child: Text(item.name)),
              ],
              onChanged: (value) => stockId = value,
              decoration: const InputDecoration(labelText: 'Feed stock'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity (bags)'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text) ?? 0;
              if (quantity <= 0) {
                return;
              }
              try {
                await ref
                    .read(feedProvider.notifier)
                    .recordUsage(
                      stockId: stockId,
                      quantity: quantity,
                      unit: 'bags',
                      usedAt: DateTime.now(),
                      notes: notesController.text,
                    );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$error')));
                }
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
    quantityController.dispose();
    notesController.dispose();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final String unit;
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
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text('$unit · $label', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _FeedTile extends StatelessWidget {
  const _FeedTile({required this.item});
  final FeedStock item;

  @override
  Widget build(BuildContext context) {
    final lowStock = item.quantity <= 5;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
          child: const Icon(
            Icons.grass_outlined,
            color: AppColors.primaryGreen,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${item.location ?? 'Farm store'} · ${lowStock ? 'Low stock' : 'In stock'}',
        ),
        trailing: Text(
          '${item.quantity.toStringAsFixed(1)} ${item.unit}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: lowStock ? AppColors.danger : null,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/components/bottom_navigation.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final feedItems = <_FeedItem>[
    _FeedItem(
      'Starter mash',
      'Feed store A',
      18,
      'bags',
      AppColors.primaryGreen,
    ),
    _FeedItem('Grower pellets', 'Feed store A', 7, 'bags', AppColors.warning),
    _FeedItem(
      'Mineral supplement',
      'Medicine room',
      3,
      'packs',
      AppColors.pigPink,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
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
          onPressed: () => _showUsageDialog(context),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showAddStockDialog(context),
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
        Text('Feed overview', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Keep an eye on what is available for the next feeding cycle.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.text.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Row(
          children: const [
            Expanded(
              child: _SummaryCard(
                label: 'Total stock',
                value: '28',
                unit: 'bags',
                icon: Icons.inventory_2_outlined,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _SummaryCard(
                label: 'Daily use',
                value: '4.5',
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
            Text('Stock levels', style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${feedItems.length} items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        ...feedItems.map((item) => _FeedTile(item: item)),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Recent usage', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.outbox_outlined),
                title: Text('Morning feeding'),
                subtitle: Text('Today · 4.5 bags used'),
                trailing: Text('08:00'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.outbox_outlined),
                title: Text('Evening feeding'),
                subtitle: Text('Yesterday · 4.2 bags used'),
                trailing: Text('17:30'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Future<void> _showAddStockDialog(BuildContext context) async {
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
                setState(
                  () => feedItems.add(
                    _FeedItem(
                      nameController.text.trim(),
                      'Feed store A',
                      quantity,
                      'bags',
                      AppColors.primaryGreen,
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
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

  Future<void> _showUsageDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record usage'),
        content: const Text(
          'Usage tracking will be connected to your daily feeding records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FeedItem {
  const _FeedItem(
    this.name,
    this.location,
    this.quantity,
    this.unit,
    this.color,
  );
  final String name;
  final String location;
  final int quantity;
  final String unit;
  final Color color;
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
  final _FeedItem item;

  @override
  Widget build(BuildContext context) {
    final lowStock = item.quantity <= 5;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.color.withValues(alpha: 0.15),
          child: Icon(Icons.grass_outlined, color: item.color),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${item.location} · ${lowStock ? 'Low stock' : 'In stock'}',
        ),
        trailing: Text(
          '${item.quantity} ${item.unit}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: lowStock ? AppColors.danger : null,
          ),
        ),
      ),
    );
  }
}

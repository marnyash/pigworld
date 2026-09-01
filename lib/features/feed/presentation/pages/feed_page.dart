import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../data/feed_api.dart';
import '../providers/feed_provider.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final Map<String, bool> _schedule = {
    'Morning': true,
    'Afternoon': false,
    'Evening': false,
  };

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Management'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: 'Search feed',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(feed.valueOrNull),
          ),
          Badge(
            smallSize: 8,
            child: IconButton(
              tooltip: 'Feed alerts',
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => _showAlerts(feed.valueOrNull),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStockDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Feed'),
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(feedProvider),
        ),
        data: (snapshot) => _Dashboard(
          snapshot: snapshot,
          schedule: _schedule,
          onScheduleChanged: (name, value) {
            setState(() => _schedule[name] = value);
            if (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name feeding marked complete')),
              );
            }
          },
          onAddFeed: _showAddStockDialog,
          onRecord: () => _showUsageDialog(snapshot),
          onOrder: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Supplier ordering will be available once suppliers are connected.',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddStockDialog() async {
    final name = TextEditingController();
    final quantity = TextEditingController();
    String unit = 'kg';
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add feed stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Feed name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('Kilograms (kg)')),
                  DropdownMenuItem(value: 'bags', child: Text('Bags')),
                ],
                onChanged: (value) => unit = value ?? unit,
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
                final amount = double.tryParse(quantity.text) ?? 0;
                if (name.text.trim().isEmpty || amount <= 0) return;
                try {
                  await ref
                      .read(feedProvider.notifier)
                      .addStock(
                        name: name.text.trim(),
                        quantity: amount,
                        unit: unit,
                      );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text('$error')));
                  }
                }
              },
              child: const Text('Add stock'),
            ),
          ],
        ),
      );
    } finally {
      name.dispose();
      quantity.dispose();
    }
  }

  Future<void> _showUsageDialog(FeedSnapshot snapshot) async {
    if (snapshot.stock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add feed stock before recording feeding.'),
        ),
      );
      return;
    }
    final quantity = TextEditingController();
    String stockId = snapshot.stock.first.id;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Record feeding'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: stockId,
                decoration: const InputDecoration(labelText: 'Feed type'),
                items: [
                  for (final item in snapshot.stock)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) => stockId = value ?? stockId,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount fed'),
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
                final amount = double.tryParse(quantity.text) ?? 0;
                if (amount <= 0) return;
                final stock = snapshot.stock.firstWhere(
                  (item) => item.id == stockId,
                );
                try {
                  await ref
                      .read(feedProvider.notifier)
                      .recordUsage(
                        stockId: stockId,
                        quantity: amount,
                        unit: stock.unit,
                        usedAt: DateTime.now(),
                      );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text('$error')));
                  }
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      );
    } finally {
      quantity.dispose();
    }
  }

  void _showSearch(FeedSnapshot? snapshot) {
    showSearch<void>(
      context: context,
      delegate: _FeedSearchDelegate(snapshot?.stock ?? const []),
    );
  }

  void _showAlerts(FeedSnapshot? snapshot) {
    final low =
        snapshot?.stock.where((item) => item.quantity <= 50).toList() ?? [];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feed alerts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _AlertRow(
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
              title: low.isEmpty
                  ? 'No low-stock feeds'
                  : '${low.length} feed type${low.length == 1 ? '' : 's'} running low',
              detail: low.isEmpty
                  ? 'Inventory is above the 50 kg reorder level.'
                  : low.map((item) => item.name).join(', '),
            ),
            const _AlertRow(
              icon: Icons.event_busy_rounded,
              color: AppColors.danger,
              title: 'Expiry dates need tracking',
              detail: 'Add expiry dates when this inventory data is available.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.snapshot,
    required this.schedule,
    required this.onScheduleChanged,
    required this.onAddFeed,
    required this.onRecord,
    required this.onOrder,
  });
  final FeedSnapshot snapshot;
  final Map<String, bool> schedule;
  final void Function(String, bool) onScheduleChanged;
  final VoidCallback onAddFeed, onRecord, onOrder;

  @override
  Widget build(BuildContext context) {
    final usedToday = snapshot.usage
        .where((item) => _isToday(item.usedAt))
        .fold<double>(0, (sum, item) => sum + item.quantity);
    final low = snapshot.stock.where((item) => item.quantity <= 50).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
      children: [
        Text(
          'Today’s feed plan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Monitor stock, feeding routines and consumption at a glance.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: 20),
        _SummaryGrid(
          metrics: [
            _Metric(
              'Total feed stock',
              _quantity(snapshot.totalQuantity),
              _stockUnit(snapshot.stock),
              Icons.inventory_2_rounded,
              AppColors.primaryGreen,
            ),
            _Metric(
              'Used today',
              _quantity(usedToday),
              _usageUnit(snapshot.usage, snapshot.stock),
              Icons.restaurant_rounded,
              AppColors.aqua,
            ),
            _Metric(
              'Low stock alert',
              '$low',
              low == 1 ? 'feed type' : 'feed types',
              Icons.warning_amber_rounded,
              AppColors.warning,
            ),
            const _Metric(
              'Monthly feed cost',
              '—',
              'record costs to track',
              Icons.payments_rounded,
              AppColors.violet,
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _SectionHeader(title: 'Quick actions'),
        const SizedBox(height: 12),
        _QuickActions(onAdd: onAddFeed, onRecord: onRecord, onOrder: onOrder),
        const SizedBox(height: 28),
        const _SectionHeader(title: 'Feeding schedule', action: 'Today'),
        const SizedBox(height: 12),
        _ScheduleCard(values: schedule, onChanged: onScheduleChanged),
        const SizedBox(height: 28),
        _SectionHeader(
          title: 'Feed inventory',
          action: '${snapshot.stock.length} types',
        ),
        const SizedBox(height: 12),
        if (snapshot.stock.isEmpty)
          const _EmptyInventory()
        else
          ...snapshot.stock.map(
            (stock) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InventoryCard(stock: stock),
            ),
          ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Daily consumption',
          action:
              '${_quantity(usedToday)} ${_usageUnit(snapshot.usage, snapshot.stock)}',
        ),
        const SizedBox(height: 12),
        _DailyConsumption(usage: snapshot.usage),
        const SizedBox(height: 28),
        const _SectionHeader(title: 'Feed analytics', action: 'Last 7 days'),
        const SizedBox(height: 12),
        _AnalyticsCard(usage: snapshot.usage),
        const SizedBox(height: 28),
        const _SectionHeader(title: 'Alerts'),
        const SizedBox(height: 12),
        _AlertsCard(
          lowStock: low,
          afternoonDone: schedule['Afternoon'] == true,
        ),
      ],
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.note, this.icon, this.color);
  final String label, value, note;
  final IconData icon;
  final Color color;
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.metrics});
  final List<_Metric> metrics;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = (box.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final metric in metrics)
            SizedBox(
              width: width,
              child: _SummaryCard(metric: metric),
            ),
        ],
      );
    },
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.metric});
  final _Metric metric;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(metric.icon, size: 20, color: metric.color),
          ),
          const SizedBox(height: 14),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            metric.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null)
        Text(
          action!,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.primaryGreen),
        ),
    ],
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onAdd,
    required this.onRecord,
    required this.onOrder,
  });
  final VoidCallback onAdd, onRecord, onOrder;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Action(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add Feed',
        onTap: onAdd,
      ),
      _Action(icon: Icons.edit_note_rounded, label: 'Record', onTap: onRecord),
      _Action(icon: Icons.sync_rounded, label: 'Update', onTap: onAdd),
      _Action(
        icon: Icons.shopping_cart_outlined,
        label: 'Order',
        onTap: onOrder,
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.deepGreen, size: 21),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.values, required this.onChanged});
  final Map<String, bool> values;
  final void Function(String, bool) onChanged;
  @override
  Widget build(BuildContext context) {
    const items = [
      ('Morning', '06:30', 'Pens A1, A2'),
      ('Afternoon', '13:00', 'Pens B1, B2'),
      ('Evening', '17:30', 'Sow house'),
    ];
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ScheduleRow(
              name: items[index].$1,
              time: items[index].$2,
              pens: items[index].$3,
              checked: values[items[index].$1] ?? false,
              onChanged: (value) => onChanged(items[index].$1, value),
            ),
            if (index < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.name,
    required this.time,
    required this.pens,
    required this.checked,
    required this.onChanged,
  });
  final String name, time, pens;
  final bool checked;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: checked ? AppColors.successContainer : AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Icon(
        checked ? Icons.check_rounded : Icons.schedule_rounded,
        color: checked ? AppColors.success : AppColors.primaryGreen,
      ),
    ),
    title: Text(
      '$name  ·  $time',
      style: Theme.of(context).textTheme.titleSmall,
    ),
    subtitle: Text(pens),
    trailing: Checkbox(
      value: checked,
      onChanged: (value) => onChanged(value ?? false),
    ),
  );
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.stock});
  final FeedStock stock;
  @override
  Widget build(BuildContext context) {
    final low = stock.quantity <= 50;
    final level = (stock.quantity / 500).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grass_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    stock.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${_quantity(stock.quantity)} ${stock.unit}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: low ? AppColors.danger : AppColors.deepGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              'Supplier: ${stock.location?.trim().isNotEmpty == true ? stock.location : 'Not assigned'}  •  Cost: —',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 4),
            Text(
              'Expiry: Not recorded',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: low ? AppColors.warning : AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: level,
                minHeight: 7,
                color: low ? AppColors.warning : AppColors.primaryGreen,
                backgroundColor: AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              low
                  ? 'Low stock — reorder soon'
                  : '${(level * 100).round()}% of target stock',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: low ? AppColors.warning : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.mutedText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No feed has been added yet. Use Add Feed to begin tracking your inventory.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DailyConsumption extends StatelessWidget {
  const _DailyConsumption({required this.usage});
  final List<FeedUsage> usage;
  @override
  Widget build(BuildContext context) {
    final today = usage.where((item) => _isToday(item.usedAt)).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: today.isEmpty
            ? const Text('No feed consumption has been recorded today.')
            : Column(
                children: [
                  for (final item in today) _ConsumptionRow(item: item),
                ],
              ),
      ),
    );
  }
}

class _ConsumptionRow extends StatelessWidget {
  const _ConsumptionRow({required this.item});
  final FeedUsage item;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        const Icon(Icons.water_drop_outlined, size: 19, color: AppColors.aqua),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.notes?.isNotEmpty == true ? item.notes! : 'Unassigned pen',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                item.feedName ?? 'Recorded feeding',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
        Text(
          '${_quantity(item.quantity)} ${item.unit}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    ),
  );
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.usage});
  final List<FeedUsage> usage;
  @override
  Widget build(BuildContext context) {
    final values = List.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      return usage
          .where(
            (item) =>
                item.usedAt.year == day.year &&
                item.usedAt.month == day.month &&
                item.usedAt.day == day.day,
          )
          .fold<double>(0, (sum, item) => sum + item.quantity);
    });
    final max = values.fold<double>(
      1,
      (current, value) => value > current ? value : current,
    );
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consumption', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            SizedBox(
              height: 112,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < 7; index++)
                    Expanded(
                      child: _ChartBar(
                        value: values[index] / max,
                        label: labels[index],
                        active: index == 6,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                  color: AppColors.violet,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Feed cost trend',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  'Awaiting cost data',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.mutedText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.value,
    required this.label,
    required this.active,
  });
  final double value;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 16,
            height: (value * 80).clamp(4, 80),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryGreen
                  : AppColors.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: active ? AppColors.primaryGreen : AppColors.mutedText,
        ),
      ),
    ],
  );
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.lowStock, required this.afternoonDone});
  final int lowStock;
  final bool afternoonDone;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        _AlertRow(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          title: lowStock == 0
              ? 'No low-stock feed'
              : '$lowStock low-stock alert${lowStock == 1 ? '' : 's'}',
          detail: lowStock == 0
              ? 'All tracked feed is above the reorder level.'
              : 'Review inventory and place an order soon.',
        ),
        const Divider(height: 1),
        const _AlertRow(
          icon: Icons.event_busy_rounded,
          color: AppColors.danger,
          title: 'Expiry dates not recorded',
          detail: 'Add expiry details to receive expiry reminders.',
        ),
        const Divider(height: 1),
        _AlertRow(
          icon: afternoonDone
              ? Icons.check_circle_outline_rounded
              : Icons.notifications_active_outlined,
          color: afternoonDone ? AppColors.success : AppColors.warning,
          title: afternoonDone
              ? 'Afternoon feeding complete'
              : 'Afternoon feeding is pending',
          detail: afternoonDone
              ? 'The scheduled pens have been checked off.'
              : 'Due at 13:00 for Pens B1, B2.',
        ),
      ],
    ),
  );
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final Color color;
  final String title, detail;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(title, style: Theme.of(context).textTheme.titleSmall),
    subtitle: Text(detail),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.danger,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load feed data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FeedSearchDelegate extends SearchDelegate<void> {
  _FeedSearchDelegate(this.stock);
  final List<FeedStock> stock;
  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
      ),
  ];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back_rounded),
  );
  @override
  Widget buildResults(BuildContext context) => _results();
  @override
  Widget buildSuggestions(BuildContext context) => _results();
  Widget _results() {
    final matches = stock
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (matches.isEmpty) {
      return const Center(child: Text('No matching feed found'));
    }
    return ListView(
      children: [
        for (final item in matches)
          ListTile(
            leading: const Icon(Icons.grass_rounded),
            title: Text(item.name),
            subtitle: Text(
              '${_quantity(item.quantity)} ${item.unit} available',
            ),
          ),
      ],
    );
  }
}

String _quantity(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
String _stockUnit(List<FeedStock> stock) => stock.isEmpty
    ? 'kg'
    : stock.map((item) => item.unit).toSet().length == 1
    ? stock.first.unit
    : 'mixed units';
String _usageUnit(List<FeedUsage> usage, List<FeedStock> stock) =>
    usage.isNotEmpty ? usage.first.unit : _stockUnit(stock);
bool _isToday(DateTime value) {
  final now = DateTime.now();
  return value.year == now.year &&
      value.month == now.month &&
      value.day == now.day;
}

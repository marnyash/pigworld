import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../data/feed_api.dart';
import '../../data/feed_schedule_local_data_source.dart';
import '../providers/feed_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final schedule = ref.watch(feedScheduleProvider);
    final currency =
        ref.watch(userPreferencesProvider).valueOrNull?.currency ?? 'KES';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Management'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'feed-stock',
            onPressed: () => context.go(AppRoutes.inventory),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Feed stock'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'record-feeding',
            onPressed: feed.valueOrNull == null
                ? null
                : () => _showUsageDialog(feed.valueOrNull!),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Record feeding'),
          ),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          error: error,
          onRetry: () => ref.invalidate(feedProvider),
        ),
        data: (snapshot) => _Dashboard(
          snapshot: snapshot,
          schedule:
              schedule.valueOrNull ?? FeedScheduleLocalDataSource.defaults,
          currency: currency,
          onScheduleChanged: (name, value) async {
            try {
              await ref
                  .read(feedScheduleProvider.notifier)
                  .setCompleted(name, value);
              if (value && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name feeding marked complete')),
                );
              }
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not save the feeding checklist.'),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _showUsageDialog(FeedSnapshot snapshot) async {
    if (snapshot.stock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Add feed stock in Inventory before recording feeding.',
          ),
          action: SnackBarAction(
            label: 'Inventory',
            onPressed: () => context.go(AppRoutes.inventory),
          ),
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
}

class _Dashboard extends StatefulWidget {
  const _Dashboard({
    required this.snapshot,
    required this.schedule,
    required this.currency,
    required this.onScheduleChanged,
  });

  final FeedSnapshot snapshot;
  final Map<String, bool> schedule;
  final String currency;
  final void Function(String, bool) onScheduleChanged;

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  late final PageController _pageController;
  int _selectedSlide = 0;

  static const _slides = [
    ('Today', Icons.schedule_rounded),
    ('Consumption', Icons.restaurant_rounded),
    ('Analytics', Icons.insights_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectSlide(int index) {
    setState(() => _selectedSlide = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final schedule = widget.schedule;
    final usedToday = snapshot.usage
        .where((item) => _isToday(item.usedAt))
        .fold<double>(0, (sum, item) => sum + item.quantity);
    final usageUnit = _usageUnit(snapshot.usage, snapshot.stock);
    final nextSchedule = _nextScheduleName(schedule);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              for (var index = 0; index < _slides.length; index++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _SlideSelector(
                      label: _slides[index].$1,
                      icon: _slides[index].$2,
                      selected: index == _selectedSlide,
                      onTap: () => _selectSlide(index),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedSlide = index),
            children: [
              _FeedSlide(
                title: 'Feeding schedule',
                subtitle: 'Today’s feeding times and completion.',
                child: _ScheduleCard(
                  values: schedule,
                  highlightedName: nextSchedule,
                  onChanged: widget.onScheduleChanged,
                ),
              ),
              _FeedSlide(
                title: 'Daily consumption',
                subtitle: 'Feed used and recorded today.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryGrid(
                      metrics: [
                        _Metric(
                          'Used today',
                          _quantity(usedToday),
                          usageUnit,
                          Icons.restaurant_rounded,
                          AppColors.aqua,
                        ),
                        _Metric(
                          'Monthly feed cost',
                          snapshot.hasMonthlyFeedCost
                              ? '${widget.currency} ${snapshot.monthlyFeedCost.toStringAsFixed(2)}'
                              : '—',
                          snapshot.hasMonthlyFeedCost
                              ? 'since the start of this month'
                              : 'add unit costs to feed stock',
                          Icons.payments_rounded,
                          AppColors.violet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DailyConsumption(usage: snapshot.usage),
                  ],
                ),
              ),
              _FeedSlide(
                title: 'Feed analytics',
                subtitle: 'Consumption trends over the last 7 days.',
                child: _AnalyticsCard(usage: snapshot.usage),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SlideSelector extends StatelessWidget {
  const _SlideSelector({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primaryGreen : AppColors.mutedText,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? AppColors.deepGreen : AppColors.mutedText,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FeedSlide extends StatelessWidget {
  const _FeedSlide({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
    key: PageStorageKey<String>(title),
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
      ),
      const SizedBox(height: 20),
      child,
    ],
  );
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

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.values,
    required this.highlightedName,
    required this.onChanged,
  });

  final Map<String, bool> values;
  final String? highlightedName;
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
              highlighted: items[index].$1 == highlightedName,
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
    required this.highlighted,
    required this.onChanged,
  });
  final String name, time, pens;
  final bool checked;
  final bool highlighted;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: checked
          ? AppColors.successContainer.withValues(alpha: .45)
          : highlighted
          ? AppColors.warningContainer.withValues(alpha: .55)
          : null,
      border: highlighted
          ? Border.all(color: AppColors.warmGold.withValues(alpha: .5))
          : null,
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: checked
              ? AppColors.successContainer
              : highlighted
              ? AppColors.warningContainer
              : AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(
          checked ? Icons.check_rounded : Icons.schedule_rounded,
          color: checked
              ? AppColors.success
              : highlighted
              ? AppColors.warning
              : AppColors.primaryGreen,
        ),
      ),
      title: Text(
        '$name  ·  $time',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: highlighted ? AppColors.deepGreen : null,
          fontWeight: highlighted ? FontWeight.w700 : null,
        ),
      ),
      subtitle: Text(pens),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (highlighted && !checked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Checkbox(
            value: checked,
            onChanged: (value) => onChanged(value ?? false),
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
String? _nextScheduleName(Map<String, bool> completed) {
  const schedule = [
    ('Morning', 6, 30),
    ('Afternoon', 13, 0),
    ('Evening', 17, 30),
  ];
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  for (final (name, hour, minute) in schedule) {
    if (!(completed[name] ?? false) && hour * 60 + minute <= currentMinutes) {
      return name;
    }
  }
  for (final (name, _, _) in schedule) {
    if (!(completed[name] ?? false)) return name;
  }
  return null;
}

bool _isToday(DateTime value) {
  final now = DateTime.now();
  return value.year == now.year &&
      value.month == now.month &&
      value.day == now.day;
}

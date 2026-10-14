import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/reports/domain/entities/report_metrics.dart';
import 'package:proj/features/reports/presentation/pages/animal_report_page.dart';
import 'package:proj/features/reports/presentation/providers/reports_providers.dart';
import 'package:proj/features/reports/presentation/widgets/herd_reports_browser.dart';
import 'package:proj/features/settings/presentation/providers/settings_providers.dart';
import 'package:proj/shared/components/bottom_navigation.dart';
import 'package:proj/shared/widgets/pig_world_icon.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(reportMetricsProvider);
    final dateRange = ref.watch(selectedDateRangeProvider);
    final currency =
        ref.watch(userPreferencesProvider).valueOrNull?.currency ?? 'KES';

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            PigWorldIcon('report', size: 24),
            SizedBox(width: AppDimensions.spacingSmall),
            Text('Reports & Analytics'),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          children: [
            _DateRangeFilter(
              selectedRange: dateRange,
              onRangeChanged: (range) {
                ref.read(selectedDateRangeProvider.notifier).state = range;
                ref.invalidate(reportMetricsProvider);
              },
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius,
                        ),
                      ),
                      child: TabBar(
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.payments_outlined),
                            text: 'Finance',
                          ),
                          Tab(icon: Icon(Icons.pets_outlined), text: 'Herd'),
                          Tab(
                            icon: Icon(Icons.pie_chart_outline),
                            text: 'Analytics',
                          ),
                        ],
                        labelColor: AppColors.primaryGreen,
                        indicatorColor: AppColors.primaryGreen,
                        unselectedLabelColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              metrics.when(
                                data: (data) => _ReportsDashboard(
                                  metrics: data,
                                  currency: currency,
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, _) =>
                                    Center(child: Text('Error: $error')),
                              ),
                              const SizedBox(
                                height: AppDimensions.spacingLarge,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.folder_open_outlined,
                                    color: AppColors.primaryGreen,
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.spacingSmall,
                                  ),
                                  Text(
                                    'Report library',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: AppDimensions.spacingMedium,
                              ),
                              const _ReportCategories(),
                            ],
                          ),
                          const SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            child: HerdReportsBrowser(),
                          ),
                          ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pie_chart_outline,
                                    color: AppColors.primaryGreen,
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.spacingSmall,
                                  ),
                                  Text(
                                    'Analytics overview',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: AppDimensions.spacingMedium,
                              ),
                              _AnalyticsCharts(
                                metrics: metrics,
                                currency: currency,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final String selectedRange;
  final Function(String) onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final ranges = ['Today', 'Week', 'Month', 'Year'];
    final rangeValues = ['today', 'week', 'month', 'year'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(ranges.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(ranges[index]),
                    selected: selectedRange == rangeValues[index],
                    onSelected: (_) => onRangeChanged(rangeValues[index]),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportsDashboard extends StatelessWidget {
  const _ReportsDashboard({required this.metrics, required this.currency});

  final ReportMetrics metrics;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payments_outlined, color: AppColors.primaryGreen),
            const SizedBox(width: AppDimensions.spacingSmall),
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        LayoutBuilder(
          builder: (context, constraints) => GridView.count(
            crossAxisCount: constraints.maxWidth < 360 ? 1 : 2,
            crossAxisSpacing: AppDimensions.spacingMedium,
            mainAxisSpacing: AppDimensions.spacingMedium,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                icon: Icons.attach_money,
                label: 'Total revenue',
                value: '$currency ${metrics.totalRevenue.toStringAsFixed(0)}',
                color: AppColors.primaryGreen,
              ),
              _MetricCard(
                icon: Icons.warning,
                label: 'Mortality Rate',
                value: '${metrics.mortalityRate.toStringAsFixed(1)}%',
                color: AppColors.danger,
              ),
              _MetricCard(
                icon: Icons.trending_up,
                label: 'Average Growth',
                value: '${metrics.averageGrowth.toStringAsFixed(1)} kg',
                color: AppColors.primaryGreen,
              ),
              _MetricCard(
                icon: Icons.restaurant,
                label: 'Feed consumed',
                value: metrics.feedConsumption.toStringAsFixed(1),
                color: AppColors.aqua,
              ),
              _MetricCard(
                icon: Icons.receipt_long_outlined,
                label: 'Total expenses',
                value: '$currency ${metrics.totalExpenses.toStringAsFixed(0)}',
                color: AppColors.aqua,
              ),
              _MetricCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Net profit',
                value: '$currency ${metrics.netProfit.toStringAsFixed(0)}',
                color: metrics.netProfit >= 0
                    ? AppColors.primaryGreen
                    : AppColors.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

enum _ChartDetail { mortality, revenue, vaccination }

class _AnalyticsCharts extends StatefulWidget {
  const _AnalyticsCharts({required this.metrics, required this.currency});

  final AsyncValue<ReportMetrics> metrics;
  final String currency;

  @override
  State<_AnalyticsCharts> createState() => _AnalyticsChartsState();
}

class _AnalyticsChartsState extends State<_AnalyticsCharts> {
  _ChartDetail _selectedDetail = _ChartDetail.mortality;

  @override
  Widget build(BuildContext context) {
    return widget.metrics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Could not load analytics: $error'),
      data: (data) {
        final chart = _chartFor(data, widget.currency, _selectedDetail);
        final total = chart.values.fold<double>(0, (sum, value) => sum + value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    chart.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final detail in _ChartDetail.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'analytics-${detail.name}',
                            tooltip: _chartLabel(detail),
                            backgroundColor: _selectedDetail == detail
                                ? AppColors.primaryGreen
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            foregroundColor: _selectedDetail == detail
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            onPressed: () =>
                                setState(() => _selectedDetail = detail),
                            child: Icon(_chartIcon(detail)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _chartLabel(detail),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(140),
                            painter: _PieChartPainter(
                              values: chart.values,
                              colors: chart.colors,
                            ),
                          ),
                          if (total <= 0)
                            const Text(
                              'No data',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (
                            var index = 0;
                            index < chart.labels.length;
                            index++
                          )
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                      color: chart.colors[index],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${chart.labels[index]}\n${chart.formattedValues[index]}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              'More metrics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            LayoutBuilder(
              builder: (context, constraints) => GridView.count(
                crossAxisCount: constraints.maxWidth < 360 ? 1 : 2,
                crossAxisSpacing: AppDimensions.spacingMedium,
                mainAxisSpacing: AppDimensions.spacingMedium,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AnalyticsMetricCard(
                    title: 'Total revenue',
                    value:
                        '${widget.currency} ${data.totalRevenue.toStringAsFixed(2)}',
                    icon: Icons.payments_outlined,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Total expenses',
                    value:
                        '${widget.currency} ${data.totalExpenses.toStringAsFixed(2)}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Net profit',
                    value:
                        '${widget.currency} ${data.netProfit.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Feed consumed',
                    value: data.feedConsumption.toStringAsFixed(1),
                    icon: Icons.restaurant_outlined,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Average weight gain',
                    value: '${data.averageGrowth.toStringAsFixed(1)} kg',
                    icon: Icons.trending_up,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Animals marked sold',
                    value: '${data.salesCount}',
                    icon: Icons.sell_outlined,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Current mortality rate',
                    value: '${data.mortalityRate.toStringAsFixed(1)}%',
                    icon: Icons.warning_amber_outlined,
                  ),
                  _AnalyticsMetricCard(
                    title: 'Vaccination completion',
                    value: '${data.vaccinationCompletion.toStringAsFixed(1)}%',
                    icon: Icons.vaccines_outlined,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _ChartData _chartFor(
    ReportMetrics metrics,
    String currency,
    _ChartDetail detail,
  ) {
    switch (detail) {
      case _ChartDetail.mortality:
        final mortality = metrics.mortalityRate.clamp(0, 100).toDouble();
        return _ChartData(
          title: 'Herd mortality',
          labels: const ['Mortality', 'Survival'],
          values: [mortality, 100 - mortality],
          formattedValues: [
            '${mortality.toStringAsFixed(1)}%',
            '${(100 - mortality).toStringAsFixed(1)}%',
          ],
          colors: const [AppColors.danger, AppColors.primaryGreen],
        );
      case _ChartDetail.revenue:
        final revenue = math.max(0.0, metrics.totalRevenue);
        final expenses = math.max(0.0, metrics.totalExpenses);
        if (metrics.netProfit >= 0) {
          return _ChartData(
            title: 'Revenue allocation',
            labels: const ['Expenses', 'Net profit'],
            values: [expenses, math.max(0.0, metrics.netProfit)],
            formattedValues: [
              '$currency ${expenses.toStringAsFixed(2)}',
              '$currency ${metrics.netProfit.toStringAsFixed(2)}',
            ],
            colors: const [AppColors.aqua, AppColors.primaryGreen],
          );
        }
        final loss = metrics.netProfit.abs();
        return _ChartData(
          title: 'Revenue and net loss',
          labels: const ['Revenue', 'Net loss'],
          values: [revenue, loss],
          formattedValues: [
            '$currency ${revenue.toStringAsFixed(2)}',
            '$currency ${loss.toStringAsFixed(2)}',
          ],
          colors: const [AppColors.primaryGreen, AppColors.danger],
        );
      case _ChartDetail.vaccination:
        final complete = metrics.vaccinationCompletion.clamp(0, 100).toDouble();
        return _ChartData(
          title: 'Vaccination completion',
          labels: const ['Complete', 'Remaining'],
          values: [complete, 100 - complete],
          formattedValues: [
            '${complete.toStringAsFixed(1)}%',
            '${(100 - complete).toStringAsFixed(1)}%',
          ],
          colors: const [AppColors.primaryGreen, AppColors.aqua],
        );
    }
  }
}

class _ChartData {
  const _ChartData({
    required this.title,
    required this.labels,
    required this.values,
    required this.formattedValues,
    required this.colors,
  });

  final String title;
  final List<String> labels;
  final List<double> values;
  final List<String> formattedValues;
  final List<Color> colors;
}

String _chartLabel(_ChartDetail detail) => switch (detail) {
  _ChartDetail.mortality => 'Herd mortality',
  _ChartDetail.revenue => 'Revenue',
  _ChartDetail.vaccination => 'Vaccinations',
};

IconData _chartIcon(_ChartDetail detail) => switch (detail) {
  _ChartDetail.mortality => Icons.warning_amber_outlined,
  _ChartDetail.revenue => Icons.payments_outlined,
  _ChartDetail.vaccination => Icons.vaccines_outlined,
};

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    if (total <= 0) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18,
      );
      return;
    }

    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value <= 0) continue;
      final sweep = 2 * math.pi * value / total;
      canvas.drawArc(
        bounds,
        start,
        sweep,
        true,
        Paint()..color = colors[index],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}

class _AnalyticsMetricCard extends StatelessWidget {
  const _AnalyticsMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _ReportCategories extends ConsumerWidget {
  const _ReportCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = [
      ('Individual Pig Report', Icons.pets, AppColors.primaryGreen),
    ];

    return GridView.count(
      crossAxisCount: reports.length == 1 ? 1 : 2,
      childAspectRatio: reports.length == 1 ? 2.8 : 1,
      crossAxisSpacing: AppDimensions.spacingMedium,
      mainAxisSpacing: AppDimensions.spacingMedium,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: reports
          .map(
            (report) => Card(
              child: InkWell(
                onTap: () {
                  _showReportDetails(context, report.$1, report.$2, report.$3);
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(report.$2, color: report.$3, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        report.$1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _showReportDetails(
    BuildContext context,
    String reportType,
    IconData icon,
    Color color,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnimalReportPage(reportType: reportType),
      ),
    );
  }
}

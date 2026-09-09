import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/reports/data/report_export_service.dart';
import 'package:proj/features/reports/presentation/providers/reports_providers.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          // Date Range Filter
          _DateRangeFilter(
            selectedRange: dateRange,
            onRangeChanged: (range) {
              ref.read(selectedDateRangeProvider.notifier).state = range;
              ref.invalidate(reportMetricsProvider);
            },
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Dashboard Cards
          metrics.when(
            data: (data) => _ReportsDashboard(metrics: data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Analytics Section
          Text('Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          _AnalyticsCharts(dateRange: dateRange),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Report Categories
          Text('Reports', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          _ReportCategories(),
          const SizedBox(height: 40),
        ],
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
              FilterChip(
                label: const Text('Custom'),
                onSelected: (_) {
                  // TODO: Show date range picker
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportsDashboard extends StatelessWidget {
  const _ReportsDashboard({required this.metrics});

  final dynamic metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spacingMedium,
          mainAxisSpacing: AppDimensions.spacingMedium,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _MetricCard(
              icon: Icons.attach_money,
              label: 'Total Revenue',
              value: 'KES ${metrics.totalRevenue.toStringAsFixed(0)}',
              color: AppColors.primaryGreen,
            ),
            _MetricCard(
              icon: Icons.trending_down,
              label: 'Total Expenses',
              value: 'KES ${metrics.totalExpenses.toStringAsFixed(0)}',
              color: AppColors.warning,
            ),
            _MetricCard(
              icon: Icons.warning,
              label: 'Mortality Rate',
              value: '${metrics.mortalityRate.toStringAsFixed(1)}%',
              color: AppColors.danger,
            ),
            _MetricCard(
              icon: Icons.trending_up,
              label: 'Avg Growth',
              value: '${metrics.averageGrowth.toStringAsFixed(1)} kg',
              color: AppColors.primaryGreen,
            ),
          ],
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

class _AnalyticsCharts extends StatelessWidget {
  const _AnalyticsCharts({required this.dateRange});

  final String dateRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChartPlaceholder(title: 'Revenue vs Expenses', icon: Icons.bar_chart),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ChartPlaceholder(title: 'Feed Consumption', icon: Icons.pie_chart),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ChartPlaceholder(title: 'Weight Growth', icon: Icons.trending_up),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ChartPlaceholder(title: 'Sales Trend', icon: Icons.line_axis),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ChartPlaceholder(
          title: 'Vaccination Completion',
          icon: Icons.health_and_safety,
        ),
      ],
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_chart_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chart data loading...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReportCategories extends ConsumerWidget {
  const _ReportCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = [
      ('Financial Report', Icons.attach_money, AppColors.primaryGreen),
      ('Herd Report', Icons.pets, AppColors.info),
      ('Health Report', Icons.health_and_safety, AppColors.danger),
      ('Feed Report', Icons.fastfood, AppColors.warmGold),
      ('Breeding Report', Icons.favorite, AppColors.pigPink),
      ('Inventory Report', Icons.inventory_2, AppColors.violet),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.spacingMedium,
      mainAxisSpacing: AppDimensions.spacingMedium,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: reports
          .map(
            (report) => Card(
              child: InkWell(
                onTap: () {
                  _showExportOptions(context, report.$1);
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

  void _showExportOptions(BuildContext context, String reportType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ExportOptionsSheet(reportType: reportType),
    );
  }
}

class _ExportOptionsSheet extends StatelessWidget {
  const _ExportOptionsSheet({required this.reportType});

  final String reportType;

  @override
  Widget build(BuildContext context) {
    final formats = [
      ('PDF', Icons.picture_as_pdf),
      ('Excel', Icons.table_chart),
      ('CSV', Icons.data_array),
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export $reportType',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          ...formats.map(
            (format) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingMedium,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showExportConfirmation(context, reportType, format.$1);
                  },
                  icon: Icon(format.$2),
                  label: Text('Export as ${format.$1}'),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportConfirmation(
    BuildContext context,
    String report,
    String format,
  ) async {
    final exportService = ReportExportService();
    final normalizedFormat = format.toLowerCase();
    final payload = {
      'report': report,
      'generatedAt': DateTime.now().toIso8601String(),
      'totalRevenue': 185000.0,
      'totalExpenses': 98000.0,
      'mortalityRate': 2.4,
      'averageGrowth': 12.8,
      'salesCount': 148,
      'vaccinationCompletion': 96.5,
    };

    try {
      final filePath = await exportService.exportReport(
        reportName: report,
        format: normalizedFormat,
        data: payload,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported $report as ${format.toUpperCase()}\n$filePath'),
          duration: const Duration(seconds: 4),
        ),
      );

      if (Platform.isAndroid || Platform.isIOS) {
        // The file was saved to the device download/documents directory.
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

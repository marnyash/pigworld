import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/reports/data/report_export_service.dart';
import 'package:proj/features/reports/presentation/pages/animal_report_page.dart';
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
          _DateRangeFilter(
            selectedRange: dateRange,
            onRangeChanged: (range) {
              ref.read(selectedDateRangeProvider.notifier).state = range;
              ref.invalidate(reportMetricsProvider);
            },
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                  ),
                  child: TabBar(
                    tabs: const [
                      Tab(text: 'Reports'),
                      Tab(text: 'Analytics'),
                    ],
                    labelColor: AppColors.primaryGreen,
                    indicatorColor: AppColors.primaryGreen,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            metrics.when(
                              data: (data) => _ReportsDashboard(metrics: data),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, _) =>
                                  Center(child: Text('Error: $error')),
                            ),
                            const SizedBox(height: AppDimensions.spacingLarge),
                            Text(
                              'Report library',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppDimensions.spacingMedium),
                            const _ReportCategories(),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analytics overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppDimensions.spacingMedium),
                            _AnalyticsCharts(dateRange: dateRange),
                          ],
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
        Text('Overview', style: Theme.of(context).textTheme.titleLarge),
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

class _ReportDetailSheet extends StatefulWidget {
  const _ReportDetailSheet({
    required this.reportType,
    required this.icon,
    required this.color,
  });

  final String reportType;
  final IconData icon;
  final Color color;

  @override
  State<_ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<_ReportDetailSheet> {
  String _selectedPig = 'All combined';

  List<String> get _pigOptions => const [
    'All combined',
    'Pig #P-204',
    'Pig #P-118',
    'Pig #P-311',
  ];

  Map<String, String> _summaryData() {
    final generatedAt = DateTime.now().toLocal().toString().split('.').first;
    final targetLabel = _selectedPig == 'All combined'
        ? 'All combined herd'
        : _selectedPig;

    switch (widget.reportType) {
      case 'Financial Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Total revenue': 'KES 185,000',
          'Total expenses': 'KES 98,000',
          'Net margin': 'KES 87,000',
          'Status': 'Healthy margin',
        };
      case 'Herd Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Active pigs': _selectedPig == 'All combined' ? '248' : '14',
          'Births this cycle': _selectedPig == 'All combined' ? '34' : '3',
          'Mortality rate': '2.4%',
          'Status': 'Stable herd growth',
        };
      case 'Health Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Vaccination completion': '96.5%',
          'Animals treated': _selectedPig == 'All combined' ? '19' : '2',
          'Follow-ups due': '6',
          'Status': 'Strong health compliance',
        };
      case 'Feed Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Feed used': _selectedPig == 'All combined' ? '1,240 kg' : '48 kg',
          'Feed cost': 'KES 32,600',
          'Utilization': '88%',
          'Status': 'Efficient feed planning',
        };
      case 'Pregnancy Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Pregnant sows': _selectedPig == 'All combined' ? '18' : '1',
          'Expected due': _selectedPig == 'All combined'
              ? '6 this month'
              : '14 days',
          'Breeding status': 'Confirmed',
          'Status': 'On track',
        };
      case 'Breeding Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Sows bred': _selectedPig == 'All combined' ? '21' : '1',
          'Scheduled breeding': _selectedPig == 'All combined' ? '9' : '1',
          'Farrowing success': '91%',
          'Status': 'Good breeding cycle',
        };
      case 'Scheduled for Breeding':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Animals scheduled': _selectedPig == 'All combined' ? '12' : '1',
          'Next due date': '2026-09-18',
          'Breeding window': '7 days',
          'Status': 'Ready for insemination',
        };
      case 'Inventory Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Stock value': 'KES 146,000',
          'Low stock items': '4',
          'Orders due': '3',
          'Status': 'Inventory is under control',
        };
      default:
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Status': 'Ready',
        };
    }
  }

  Future<void> _downloadReport(BuildContext context, String format) async {
    final exportService = ReportExportService();
    final payload = {
      'report': widget.reportType,
      'pigSelection': _selectedPig,
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
        reportName: widget.reportType,
        format: format.toLowerCase(),
        data: payload,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${widget.reportType} as ${format.toUpperCase()}\n$filePath',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final summary = _summaryData();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.reportType,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text('Scope', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pigOptions.map((pig) {
                final isSelected = pig == _selectedPig;
                return ChoiceChip(
                  label: Text(pig),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedPig = pig),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radius),
              ),
              child: Column(
                children: summary.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingSmall,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailViewPage(
                        reportType: widget.reportType,
                        icon: widget.icon,
                        color: widget.color,
                        initialPig: _selectedPig,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View on screen'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadReport(context, 'PDF');
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadReport(context, 'Excel');
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Excel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailViewPage extends StatefulWidget {
  const ReportDetailViewPage({
    super.key,
    required this.reportType,
    required this.icon,
    required this.color,
    this.initialPig = 'All combined',
  });

  final String reportType;
  final IconData icon;
  final Color color;
  final String initialPig;

  @override
  State<ReportDetailViewPage> createState() => _ReportDetailViewPageState();
}

class _ReportDetailViewPageState extends State<ReportDetailViewPage> {
  late String _selectedPig;
  final TextEditingController _animalController = TextEditingController();

  List<String> get _pigOptions => const [
    'All combined',
    'Pig #P-204',
    'Pig #P-118',
    'Pig #P-311',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPig = widget.initialPig;
    _animalController.text = _selectedPig;
  }

  @override
  void dispose() {
    _animalController.dispose();
    super.dispose();
  }

  Map<String, String> _summaryData() {
    final generatedAt = DateTime.now().toLocal().toString().split('.').first;
    final targetLabel = _selectedPig == 'All combined'
        ? 'All combined herd'
        : _selectedPig;

    switch (widget.reportType) {
      case 'Financial Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Total revenue': 'KES 185,000',
          'Total expenses': 'KES 98,000',
          'Net margin': 'KES 87,000',
          'Status': 'Healthy margin',
        };
      case 'Herd Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Active pigs': _selectedPig == 'All combined' ? '248' : '14',
          'Births this cycle': _selectedPig == 'All combined' ? '34' : '3',
          'Mortality rate': '2.4%',
          'Status': 'Stable herd growth',
        };
      case 'Health Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Vaccination completion': '96.5%',
          'Animals treated': _selectedPig == 'All combined' ? '19' : '2',
          'Follow-ups due': '6',
          'Status': 'Strong health compliance',
        };
      case 'Feed Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Feed used': _selectedPig == 'All combined' ? '1,240 kg' : '48 kg',
          'Feed cost': 'KES 32,600',
          'Utilization': '88%',
          'Status': 'Efficient feed planning',
        };
      case 'Pregnancy Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Pregnant sows': _selectedPig == 'All combined' ? '18' : '1',
          'Expected due': _selectedPig == 'All combined'
              ? '6 this month'
              : '14 days',
          'Breeding status': 'Confirmed',
          'Status': 'On track',
        };
      case 'Breeding Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Sows bred': _selectedPig == 'All combined' ? '21' : '1',
          'Scheduled breeding': _selectedPig == 'All combined' ? '9' : '1',
          'Farrowing success': '91%',
          'Status': 'Good breeding cycle',
        };
      case 'Scheduled for Breeding':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Animals scheduled': _selectedPig == 'All combined' ? '12' : '1',
          'Next due date': '2026-09-18',
          'Breeding window': '7 days',
          'Status': 'Ready for insemination',
        };
      case 'Inventory Report':
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Stock value': 'KES 146,000',
          'Low stock items': '4',
          'Orders due': '3',
          'Status': 'Inventory is under control',
        };
      default:
        return {
          'Target': targetLabel,
          'Generated': generatedAt,
          'Status': 'Ready',
        };
    }
  }

  void _applyAnimalSelection(String value) {
    setState(() {
      _selectedPig = value;
      _animalController.text = value;
    });
  }

  Future<void> _downloadReport(BuildContext context, String format) async {
    final exportService = ReportExportService();
    final payload = {
      'report': widget.reportType,
      'pigSelection': _selectedPig,
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
        reportName: widget.reportType,
        format: format.toLowerCase(),
        data: payload,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${widget.reportType} as ${format.toUpperCase()}\n$filePath',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final summary = _summaryData();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reportType),
        actions: [
          IconButton(
            onPressed: () => _downloadReport(context, 'PDF'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Animal report view',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              'Search animal or herd',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _animalController,
              decoration: InputDecoration(
                hintText: 'Search by animal ID',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _pigOptions.contains(_selectedPig)
                          ? _selectedPig
                          : null,
                      hint: const Icon(Icons.arrow_drop_down),
                      icon: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                      items: _pigOptions
                          .map(
                            (pig) =>
                                DropdownMenuItem(value: pig, child: Text(pig)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _applyAnimalSelection(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                final trimmed = value.trim();
                if (trimmed.isEmpty) {
                  setState(() => _selectedPig = 'All combined');
                  return;
                }

                final matched = _pigOptions.firstWhere(
                  (pig) => pig.toLowerCase() == trimmed.toLowerCase(),
                  orElse: () => trimmed,
                );

                setState(() => _selectedPig = matched);
              },
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radius),
              ),
              child: Column(
                children: summary.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingSmall,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _downloadReport(context, 'PDF'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadReport(context, 'Excel'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Excel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

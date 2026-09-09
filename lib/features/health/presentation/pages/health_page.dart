import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../providers/health_providers.dart';
import '../widgets/health_overview_card.dart';
import '../widgets/health_alerts_section.dart';
import '../widgets/vaccination_schedule_section.dart';
import '../widgets/treatment_records_section.dart';
import '../widgets/veterinary_visits_section.dart';
import '../widgets/health_analytics_section.dart';
import '../widgets/add_health_record_dialog.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Health Management'),
      leading: IconButton(
        tooltip: 'Back to home',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.home),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Records'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        // Overview Tab
        _buildOverviewTab(context, ref),
        // Records Tab
        _buildRecordsTab(context, ref),
        // Analytics Tab
        _buildAnalyticsTab(context, ref),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showAddHealthRecordDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Add Record'),
    ),
  );

  Widget _buildOverviewTab(
    BuildContext context,
    WidgetRef ref,
  ) => RefreshIndicator(
    onRefresh: () => ref.refresh(healthRecordsProvider.future),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        100,
      ),
      children: [
        // Health Status Overview Cards
        _buildHealthOverview(ref),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Health Alerts Section
        Text('Health Alerts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        const HealthAlertsSection(),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Vaccination Schedule
        Text(
          'Vaccination Schedule',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        const VaccinationScheduleSection(),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Treatment Records
        Text(
          'Treatment Records',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        const TreatmentRecordsSection(),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Veterinary Visits
        Text(
          'Veterinary Visits',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        const VeterinaryVisitsSection(),
      ],
    ),
  );

  Widget _buildRecordsTab(
    BuildContext context,
    WidgetRef ref,
  ) => RefreshIndicator(
    onRefresh: () => ref.refresh(healthRecordsProvider.future),
    child: Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              TextField(
                onChanged: (value) {
                  ref.read(healthSearchProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search by pig ID, RFID, or diagnosis...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All Types',
                      isSelected: _typeFilter == 'all',
                      onSelected: () {
                        setState(() => _typeFilter = 'all');
                        ref.read(healthTypeFilterProvider.notifier).state =
                            'all';
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Vaccination',
                      isSelected: _typeFilter == 'vaccination',
                      onSelected: () {
                        setState(() => _typeFilter = 'vaccination');
                        ref.read(healthTypeFilterProvider.notifier).state =
                            'vaccination';
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Treatment',
                      isSelected: _typeFilter == 'treatment',
                      onSelected: () {
                        setState(() => _typeFilter = 'treatment');
                        ref.read(healthTypeFilterProvider.notifier).state =
                            'treatment';
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Deworming',
                      isSelected: _typeFilter == 'deworming',
                      onSelected: () {
                        setState(() => _typeFilter = 'deworming');
                        ref.read(healthTypeFilterProvider.notifier).state =
                            'deworming';
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Filtered Records List
        Expanded(
          child: ref
              .watch(filteredHealthRecordsProvider)
              .when(
                data: (records) {
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.health_and_safety_outlined,
                            size: 64,
                            color: AppColors.mutedText,
                          ),
                          const SizedBox(height: AppDimensions.spacingMedium),
                          Text(
                            'No health records found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePadding,
                      0,
                      AppDimensions.pagePadding,
                      100,
                    ),
                    itemCount: records.length,
                    itemBuilder: (context, index) => _HealthRecordCard(
                      record: records[index],
                      onDelete: () {
                        ref
                            .read(healthRecordsProvider.notifier)
                            .deleteRecord(records[index].id);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Text(
                        'Failed to load records',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.spacingSmall),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ],
    ),
  );

  Widget _buildAnalyticsTab(BuildContext context, WidgetRef ref) =>
      const HealthAnalyticsSection();

  Widget _buildHealthOverview(WidgetRef ref) {
    return ref
        .watch(healthOverviewProvider)
        .when(
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.spacingMedium,
            mainAxisSpacing: AppDimensions.spacingMedium,
            // The overview cards contain an icon, value, and label. Giving
            // them a little more height prevents their content from clipping
            // on narrow phone screens.
            childAspectRatio: 0.85,
            children: [
              HealthOverviewCard(
                label: 'Healthy Pigs',
                value: stats['healthy']?.toString() ?? '0',
                icon: Icons.favorite,
                color: AppColors.success,
              ),
              HealthOverviewCard(
                label: 'Sick Pigs',
                value: stats['sick']?.toString() ?? '0',
                icon: Icons.local_hospital,
                color: AppColors.warning,
              ),
              HealthOverviewCard(
                label: 'Vaccinations Due',
                value: stats['vaccinations_due']?.toString() ?? '0',
                icon: Icons.vaccines,
                color: AppColors.info,
              ),
              HealthOverviewCard(
                label: 'Under Treatment',
                value: stats['under_treatment']?.toString() ?? '0',
                icon: Icons.medical_services_outlined,
                color: AppColors.violet,
              ),
            ],
          ),
          loading: () => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.spacingMedium,
            mainAxisSpacing: AppDimensions.spacingMedium,
            childAspectRatio: 0.85,
            children: List.generate(
              4,
              (index) =>
                  const Card(child: Center(child: CircularProgressIndicator())),
            ),
          ),
          error: (error, stackTrace) => Card(
            color: AppColors.dangerContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              child: Text(
                'Failed to load health overview',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ),
        );
  }

  void _showAddHealthRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddHealthRecordDialog(
        onSubmit: (data) {
          ref.read(healthRecordsProvider.notifier).addRecord(data);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) => onSelected(),
    selectedColor: AppColors.primaryGreen,
    labelStyle: TextStyle(
      color: isSelected ? AppColors.inverseText : AppColors.text,
    ),
  );
}

// Health Record Card Widget
class _HealthRecordCard extends StatelessWidget {
  final dynamic record;
  final VoidCallback onDelete;

  const _HealthRecordCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
    child: ListTile(
      leading: Icon(
        _getTypeIcon(record.type),
        color: _getTypeColor(record.type),
        size: 32,
      ),
      title: Text(
        'Pig ${record.pigId}',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('RFID: ${record.rfid}'),
          if (record.diagnosis != null) Text('Diagnosis: ${record.diagnosis}'),
          Text(
            'Date: ${record.visitDate.toString().split(' ')[0]}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      isThreeLine: true,
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(child: const Text('Edit'), onTap: () {}),
          PopupMenuItem(
            onTap: onDelete,
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    ),
  );

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines;
      case 'treatment':
        return Icons.local_hospital;
      case 'deworming':
        return Icons.health_and_safety;
      case 'mortality':
        return Icons.highlight_off;
      default:
        return Icons.info;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'vaccination':
        return AppColors.info;
      case 'treatment':
        return AppColors.warning;
      case 'deworming':
        return AppColors.primaryGreen;
      case 'mortality':
        return AppColors.danger;
      default:
        return AppColors.text;
    }
  }
}

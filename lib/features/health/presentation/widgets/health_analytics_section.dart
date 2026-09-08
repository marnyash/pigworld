import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../providers/health_providers.dart';

class HealthAnalyticsSection extends ConsumerWidget {
  const HealthAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RefreshIndicator(
    onRefresh: () => ref.refresh(healthAnalyticsProvider.future),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        100,
      ),
      children: [
        Text('Health Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        ref
            .watch(healthOverviewProvider)
            .when(
              data: (stats) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppDimensions.spacingMedium,
                mainAxisSpacing: AppDimensions.spacingMedium,
                children: [
                  _AnalyticsCard(
                    label: 'Healthy Pigs',
                    value: '${stats['healthy'] ?? 0}',
                    percentage: '95%',
                    color: AppColors.success,
                    icon: Icons.favorite,
                  ),
                  _AnalyticsCard(
                    label: 'Sick Pigs',
                    value: '${stats['sick'] ?? 0}',
                    percentage: '5%',
                    color: AppColors.warning,
                    icon: Icons.local_hospital,
                  ),
                  _AnalyticsCard(
                    label: 'Vaccinations Due',
                    value: '${stats['vaccinations_due'] ?? 0}',
                    percentage: 'Pending',
                    color: AppColors.info,
                    icon: Icons.vaccines,
                  ),
                  _AnalyticsCard(
                    label: 'Under Treatment',
                    value: '${stats['under_treatment'] ?? 0}',
                    percentage: 'Active',
                    color: AppColors.violet,
                    icon: Icons.medical_services_outlined,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Card(
                color: AppColors.dangerContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                  child: Text(
                    'Failed to load analytics',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text(
          'Disease Incidence',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ChartPlaceholder(title: 'Common Diseases (Last 30 days)', height: 200),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Vaccination Rate', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vaccination Completion',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      '88%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.spacingSmall,
                  ),
                  child: LinearProgressIndicator(
                    value: 0.88,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '88 out of 100 pigs vaccinated',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Mortality Rate', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mortality Rate',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      '1.2%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                Text(
                  'Last 30 days: 2 pigs',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Recovery Trends', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ChartPlaceholder(title: 'Average Recovery Time (Days)', height: 180),
      ],
    ),
  );
}

class _AnalyticsCard extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final IconData icon;

  const _AnalyticsCard({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    ),
  );
}

class _ChartPlaceholder extends StatelessWidget {
  final String title;
  final double height;

  const _ChartPlaceholder({required this.title, required this.height});

  @override
  Widget build(BuildContext context) => Card(
    child: Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            color: AppColors.primaryGreen,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primaryGreen),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Chart visualization coming soon',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

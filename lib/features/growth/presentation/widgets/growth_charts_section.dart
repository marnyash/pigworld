import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../providers/growth_providers.dart';

class GrowthChartsSection extends ConsumerWidget {
  const GrowthChartsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(growthPeriodFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppDimensions.spacingSmall,
          children: [
            _PeriodChip(
              label: '7 days',
              isSelected: selectedPeriod == '7days',
              onTap: () {
                ref.read(growthPeriodFilterProvider.notifier).state = '7days';
              },
            ),
            _PeriodChip(
              label: '30 days',
              isSelected: selectedPeriod == '30days',
              onTap: () {
                ref.read(growthPeriodFilterProvider.notifier).state = '30days';
              },
            ),
            _PeriodChip(
              label: '3 months',
              isSelected: selectedPeriod == '90days',
              onTap: () {
                ref.read(growthPeriodFilterProvider.notifier).state = '90days';
              },
            ),
            _PeriodChip(
              label: '1 year',
              isSelected: selectedPeriod == '1year',
              onTap: () {
                ref.read(growthPeriodFilterProvider.notifier).state = '1year';
              },
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        ref
            .watch(growthAnalyticsProvider(selectedPeriod))
            .when(
              data: (analytics) => _ChartPlaceholder(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.3),
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryGreen
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'Weight Trend Chart',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Interactive chart coming soon',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

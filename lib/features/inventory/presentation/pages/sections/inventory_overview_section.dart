import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/inventory/presentation/providers/inventory_providers.dart';

class InventoryOverviewSection extends ConsumerWidget {
  const InventoryOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(inventoryOverviewProvider);

    return overview.when(
      data: (data) => ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Text(
            'Inventory Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.spacingMedium,
            mainAxisSpacing: AppDimensions.spacingMedium,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _SummaryCard(
                icon: Icons.inventory_2,
                label: 'Total Items',
                value: data['totalItems'].toString(),
                color: AppColors.primaryGreen,
              ),
              _SummaryCard(
                icon: Icons.warning_amber,
                label: 'Low Stock',
                value: data['lowStockCount'].toString(),
                color: AppColors.warmGold,
              ),
              _SummaryCard(
                icon: Icons.access_time,
                label: 'Expiring Soon',
                value: data['expiringCount'].toString(),
                color: Colors.orange,
              ),
              _SummaryCard(
                icon: Icons.attach_money,
                label: 'Total Value (KES)',
                value:
                    'KES ${(data['totalValue'] as double).toStringAsFixed(0)}',
                color: AppColors.pigPink,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Alerts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data['activeAlerts']} alerts require attention',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: Navigate to alerts tab
                      },
                      icon: const Icon(Icons.notifications),
                      label: const Text('View Alerts'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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

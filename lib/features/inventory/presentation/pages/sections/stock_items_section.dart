import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/inventory/presentation/providers/inventory_providers.dart';

class StockItemsSection extends ConsumerWidget {
  const StockItemsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryItemsProvider);

    return items.when(
      data: (inventoryItems) => ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          if (inventoryItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Text(
                  'No inventory items yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...inventoryItems.map(
              (item) => Card(
                margin: const EdgeInsets.only(
                  bottom: AppDimensions.spacingMedium,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStockColor(
                                item,
                              ).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: _getStockColor(item),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.category} • ${item.sku}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              item.stockStatus,
                              style: TextStyle(
                                color: _getStockColor(item),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: _getStockColor(
                              item,
                            ).withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Stock',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${item.quantity} ${item.unit}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Minimum Level',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${item.minimumLevel} ${item.unit}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cost Price',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'KES ${item.costPrice.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supplier',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                item.supplier,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          if (item.expiryDate != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expires',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  item.expiryDate.toString().split(' ')[0],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: item.isExpired
                                            ? Colors.red
                                            : null,
                                      ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Row(
                        children: [
                          Text(
                            'Location: ${item.storageLocation}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (item.barcode != null)
                            Expanded(
                              child: Text(
                                ' • Barcode: ${item.barcode}',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Edit item
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: () {
                              // TODO: Record stock movement
                            },
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Movement'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Color _getStockColor(dynamic item) {
    if (item.isExpired) return Colors.red;
    if (item.isExpiringExpiry) return Colors.orange;
    if (item.isLowStock) return AppColors.warmGold;
    return AppColors.primaryGreen;
  }
}

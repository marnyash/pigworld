import 'package:riverpod/riverpod.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';
import 'package:proj/features/inventory/data/inventory_api.dart';
import 'package:proj/features/inventory/data/inventory_local_data_source.dart';
import 'package:proj/features/inventory/domain/entities/inventory_alert.dart';
import 'package:proj/features/inventory/domain/entities/inventory_item.dart';
import 'package:proj/features/inventory/domain/entities/stock_movement.dart';
import 'package:proj/features/inventory/domain/entities/supplier.dart';

// Data source provider
final inventoryLocalDataSourceProvider = Provider(
  (_) => InventoryLocalDataSource(),
);

// API provider
final inventoryApiProvider = Provider(
  (ref) => InventoryApi(ref.watch(dioProvider)),
);

// Inventory Items Provider
class InventoryItemsNotifier extends AsyncNotifier<List<InventoryItem>> {
  @override
  Future<List<InventoryItem>> build() async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    return local.readItems();
  }

  Future<void> createItem(InventoryItem item) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.saveItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateItem(InventoryItem item) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.saveItem(item);
    ref.invalidateSelf();
  }

  Future<void> deleteItem(String itemId) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.deleteItem(itemId);
    ref.invalidateSelf();
  }
}

final inventoryItemsProvider =
    AsyncNotifierProvider<InventoryItemsNotifier, List<InventoryItem>>(
      InventoryItemsNotifier.new,
    );

// Inventory Alerts Provider
class InventoryAlertsNotifier extends AsyncNotifier<List<InventoryAlert>> {
  @override
  Future<List<InventoryAlert>> build() async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    final alerts = await local.readAlerts();
    return alerts.where((a) => !a.isResolved).toList();
  }

  Future<void> generateAlerts() async {
    final items = await ref.watch(inventoryItemsProvider.future);
    final local = ref.watch(inventoryLocalDataSourceProvider);

    final alerts = <InventoryAlert>[];

    for (final item in items) {
      // Low stock alert
      if (item.isLowStock) {
        alerts.add(
          InventoryAlert(
            id: 'low_${item.id}',
            itemId: item.id,
            itemName: item.name,
            alertType: 'low_stock',
            severity: 'warning',
            message:
                '${item.name} stock is below minimum level (${item.quantity} ${item.unit})',
            isResolved: false,
            createdAt: DateTime.now(),
            resolvedAt: null,
          ),
        );
      }

      // Expiring soon alert
      if (item.isExpiringExpiry) {
        alerts.add(
          InventoryAlert(
            id: 'expiring_${item.id}',
            itemId: item.id,
            itemName: item.name,
            alertType: 'expiring',
            severity: 'critical',
            message:
                '${item.name} is expiring on ${item.expiryDate?.toString().split(' ')[0]}',
            isResolved: false,
            createdAt: DateTime.now(),
            resolvedAt: null,
          ),
        );
      }

      // Expired alert
      if (item.isExpired) {
        alerts.add(
          InventoryAlert(
            id: 'expired_${item.id}',
            itemId: item.id,
            itemName: item.name,
            alertType: 'expired',
            severity: 'critical',
            message: '${item.name} has expired',
            isResolved: false,
            createdAt: DateTime.now(),
            resolvedAt: null,
          ),
        );
      }
    }

    for (final alert in alerts) {
      await local.saveAlert(alert);
    }
    ref.invalidateSelf();
  }

  Future<void> resolveAlert(String alertId) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.resolveAlert(alertId);
    ref.invalidateSelf();
  }
}

final inventoryAlertsProvider =
    AsyncNotifierProvider<InventoryAlertsNotifier, List<InventoryAlert>>(
      InventoryAlertsNotifier.new,
    );

// Suppliers Provider
class SuppliersNotifier extends AsyncNotifier<List<Supplier>> {
  @override
  Future<List<Supplier>> build() async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    return local.readSuppliers();
  }

  Future<void> createSupplier(Supplier supplier) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.saveSupplier(supplier);
    ref.invalidateSelf();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.saveSupplier(supplier);
    ref.invalidateSelf();
  }
}

final suppliersProvider =
    AsyncNotifierProvider<SuppliersNotifier, List<Supplier>>(
      SuppliersNotifier.new,
    );

// Stock Movements Provider
class StockMovementsNotifier extends AsyncNotifier<List<StockMovement>> {
  @override
  Future<List<StockMovement>> build() async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    return local.readMovements();
  }

  Future<void> recordMovement(StockMovement movement) async {
    final local = ref.watch(inventoryLocalDataSourceProvider);
    await local.recordMovement(movement);

    // Update item quantity
    final items = await ref.watch(inventoryItemsProvider.future);
    final itemIndex = items.indexWhere((i) => i.id == movement.itemId);
    if (itemIndex >= 0) {
      final item = items[itemIndex];
      double newQuantity = item.quantity;

      switch (movement.movementType) {
        case 'in':
          newQuantity += movement.quantity;
          break;
        case 'out':
        case 'damaged':
        case 'returned':
          newQuantity -= movement.quantity;
          break;
        case 'transfer':
          // No quantity change for transfers
          break;
      }

      final updatedItem = item.copyWith(quantity: newQuantity);
      await local.saveItem(updatedItem);
      ref.invalidate(inventoryItemsProvider);
    }

    ref.invalidateSelf();
    await ref.read(inventoryAlertsProvider.notifier).generateAlerts();
  }
}

final stockMovementsProvider =
    AsyncNotifierProvider<StockMovementsNotifier, List<StockMovement>>(
      StockMovementsNotifier.new,
    );

// Inventory Overview Provider (computed from items)
final inventoryOverviewProvider = FutureProvider((ref) async {
  final items = await ref.watch(inventoryItemsProvider.future);
  final alerts = await ref.watch(inventoryAlertsProvider.future);

  return {
    'totalItems': items.length,
    'lowStockCount': items.where((i) => i.isLowStock).length,
    'expiringCount': items.where((i) => i.isExpiringExpiry).length,
    'totalValue': items.fold<double>(0, (sum, item) => sum + item.totalValue),
    'activeAlerts': alerts.length,
  };
});

// Filtered items by category
final filteredInventoryProvider = FutureProvider.family((
  ref,
  String category,
) async {
  final items = await ref.watch(inventoryItemsProvider.future);
  if (category.isEmpty) return items;
  return items.where((item) => item.category == category).toList();
});

// Search items
final searchInventoryProvider = FutureProvider.family((
  ref,
  String query,
) async {
  final items = await ref.watch(inventoryItemsProvider.future);
  if (query.isEmpty) return items;
  final lowerQuery = query.toLowerCase();
  return items
      .where(
        (item) =>
            item.name.toLowerCase().contains(lowerQuery) ||
            item.sku.toLowerCase().contains(lowerQuery) ||
            (item.barcode?.toLowerCase().contains(lowerQuery) ?? false),
      )
      .toList();
});

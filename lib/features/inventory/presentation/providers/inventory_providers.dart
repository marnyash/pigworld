import 'package:riverpod/riverpod.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';
import 'package:proj/features/inventory/data/inventory_api.dart';
import 'package:proj/features/inventory/domain/entities/inventory_item.dart';
import 'package:proj/features/inventory/domain/entities/stock_movement.dart';

// API provider
final inventoryApiProvider = Provider(
  (ref) => InventoryApi(ref.watch(dioProvider)),
);

// Fetch inventory items for current farm
final inventoryItemsProvider =
    FutureProvider.autoDispose<
      ({List<InventoryItem> items, Map<String, dynamic> summary})
    >((ref) async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final result = await api.fetchItems(auth!.selectedFarm!.id);
      return (
        items: result['items'] as List<InventoryItem>,
        summary: result['summary'] as Map<String, dynamic>,
      );
    });

// Fetch a single inventory item with its movements
final inventoryItemDetailsProvider = FutureProvider.autoDispose
    .family<({InventoryItem item, List<StockMovement> movements}), String>((
      ref,
      itemId,
    ) async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final result = await api.fetchItem(auth!.selectedFarm!.id, itemId);
      return (
        item: result['item'] as InventoryItem,
        movements: result['movements'] as List<StockMovement>,
      );
    });

// Fetch inventory alerts
final inventoryAlertsProvider =
    FutureProvider.autoDispose<
      ({
        List<InventoryItem> lowStock,
        List<InventoryItem> expiring,
        List<InventoryItem> expired,
      })
    >((ref) async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final result = await api.fetchAlerts(auth!.selectedFarm!.id);
      return (
        lowStock: result['lowStock'] as List<InventoryItem>,
        expiring: result['expiring'] as List<InventoryItem>,
        expired: result['expired'] as List<InventoryItem>,
      );
    });

// Fetch items by category
final inventoryCategoryProvider = FutureProvider.autoDispose
    .family<({List<InventoryItem> items, int count}), String>((
      ref,
      category,
    ) async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final result = await api.fetchByCategory(
        auth!.selectedFarm!.id,
        category,
      );
      return (
        items: result['items'] as List<InventoryItem>,
        count: result['count'] as int,
      );
    });

// Create inventory item notifier
class CreateInventoryItemNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<InventoryItem> createItem({
    required String name,
    required String category,
    required String sku,
    required double quantity,
    required String unit,
    required double minimumLevel,
    required double costPrice,
    String? supplier,
    DateTime? expiryDate,
    String? storageLocation,
    String? barcode,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final item = await api.createItem(
        auth!.selectedFarm!.id,
        name: name,
        category: category,
        sku: sku,
        quantity: quantity,
        unit: unit,
        minimumLevel: minimumLevel,
        costPrice: costPrice,
        supplier: supplier,
        expiryDate: expiryDate,
        storageLocation: storageLocation,
        barcode: barcode,
        notes: notes,
      );

      // Invalidate the items list to trigger refresh
      ref.invalidate(inventoryItemsProvider);
      ref.invalidate(inventoryAlertsProvider);

      return item;
    });

    if (state.hasError) {
      rethrow;
    }
  }
}

final createInventoryItemProvider =
    AsyncNotifierProvider<CreateInventoryItemNotifier, void>(
      CreateInventoryItemNotifier.new,
    );

// Update inventory item notifier
class UpdateInventoryItemNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<InventoryItem> updateItem(
    String itemId, {
    String? name,
    String? category,
    String? sku,
    double? quantity,
    String? unit,
    double? minimumLevel,
    double? costPrice,
    String? supplier,
    DateTime? expiryDate,
    String? storageLocation,
    String? barcode,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final item = await api.updateItem(
        auth!.selectedFarm!.id,
        itemId,
        name: name,
        category: category,
        sku: sku,
        quantity: quantity,
        unit: unit,
        minimumLevel: minimumLevel,
        costPrice: costPrice,
        supplier: supplier,
        expiryDate: expiryDate,
        storageLocation: storageLocation,
        barcode: barcode,
        notes: notes,
      );

      // Invalidate relevant providers
      ref.invalidate(inventoryItemsProvider);
      ref.invalidate(inventoryItemDetailsProvider(itemId));
      ref.invalidate(inventoryAlertsProvider);

      return item;
    });

    if (state.hasError) {
      rethrow;
    }
  }
}

final updateInventoryItemProvider =
    AsyncNotifierProvider<UpdateInventoryItemNotifier, void>(
      UpdateInventoryItemNotifier.new,
    );

// Delete inventory item notifier
class DeleteInventoryItemNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      await api.deleteItem(auth!.selectedFarm!.id, itemId);

      // Invalidate relevant providers
      ref.invalidate(inventoryItemsProvider);
      ref.invalidate(inventoryItemDetailsProvider(itemId));
      ref.invalidate(inventoryAlertsProvider);
    });

    if (state.hasError) {
      rethrow;
    }
  }
}

final deleteInventoryItemProvider =
    AsyncNotifierProvider<DeleteInventoryItemNotifier, void>(
      DeleteInventoryItemNotifier.new,
    );

// Record stock movement notifier
class RecordMovementNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<StockMovement> recordMovement(
    String itemId, {
    required String type,
    required double quantity,
    String? reference,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.watch(inventoryApiProvider);
      final auth = ref.watch(authProvider).valueOrNull;

      if (auth?.selectedFarm?.id == null) {
        throw Exception('No farm selected');
      }

      final movement = await api.recordMovement(
        auth!.selectedFarm!.id,
        itemId,
        type: type,
        quantity: quantity,
        reference: reference,
        notes: notes,
      );

      // Invalidate relevant providers
      ref.invalidate(inventoryItemsProvider);
      ref.invalidate(inventoryItemDetailsProvider(itemId));
      ref.invalidate(inventoryAlertsProvider);

      return movement;
    });

    if (state.hasError) {
      rethrow;
    }
  }
}

final recordMovementProvider =
    AsyncNotifierProvider<RecordMovementNotifier, void>(
      RecordMovementNotifier.new,
    );

// Selected filter providers
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'Feed');
final selectedStatusFilterProvider = StateProvider<String>(
  (ref) => 'all',
); // 'all', 'low_stock', 'expiring'

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

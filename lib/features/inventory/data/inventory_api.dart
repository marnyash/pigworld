import 'package:dio/dio.dart';
import 'package:proj/core/errors/error_handler.dart';
import 'package:proj/features/inventory/domain/entities/inventory_item.dart';
import 'package:proj/features/inventory/domain/entities/stock_movement.dart';
import 'package:proj/features/inventory/domain/entities/supplier.dart';

/// API client for inventory operations
class InventoryApi {
  InventoryApi(this._dio);

  final Dio _dio;

  // Inventory Items
  Future<List<InventoryItem>> fetchItems(String farmId) async {
    try {
      final response = await _dio.get('/farms/$farmId/inventory/items');
      final items = response.data as List<dynamic>;
      return items
          .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  Future<InventoryItem> createItem(String farmId, InventoryItem item) async {
    try {
      final data = <String, dynamic>{
        'name': item.name,
        'category': item.category,
        'sku': item.sku,
        'quantity': item.quantity,
        'unit': item.unit,
        'minimumLevel': item.minimumLevel,
        'supplier': item.supplier,
        'costPrice': item.costPrice,
        'storageLocation': item.storageLocation,
        if (item.expiryDate != null)
          'expiryDate': item.expiryDate!.toIso8601String(),
        if (item.barcode != null) 'barcode': item.barcode,
      };
      final response = await _dio.post(
        '/farms/$farmId/inventory/items',
        data: data,
      );
      return InventoryItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<InventoryItem> updateItem(
    String farmId,
    String itemId,
    InventoryItem item,
  ) async {
    try {
      final data = <String, dynamic>{
        'name': item.name,
        'category': item.category,
        'sku': item.sku,
        'quantity': item.quantity,
        'unit': item.unit,
        'minimumLevel': item.minimumLevel,
        'supplier': item.supplier,
        'costPrice': item.costPrice,
        'storageLocation': item.storageLocation,
        if (item.expiryDate != null)
          'expiryDate': item.expiryDate!.toIso8601String(),
        if (item.barcode != null) 'barcode': item.barcode,
      };
      final response = await _dio.patch(
        '/farms/$farmId/inventory/items/$itemId',
        data: data,
      );
      return InventoryItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> deleteItem(String farmId, String itemId) async {
    try {
      await _dio.delete('/farms/$farmId/inventory/items/$itemId');
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Stock Movements
  Future<List<StockMovement>> fetchMovements(String farmId) async {
    try {
      final response = await _dio.get('/farms/$farmId/inventory/movements');
      final movements = response.data as List<dynamic>;
      return movements
          .map(
            (movement) =>
                StockMovement.fromJson(movement as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<StockMovement> recordMovement(
    String farmId,
    StockMovement movement,
  ) async {
    try {
      final data = {
        'itemId': movement.itemId,
        'movementType': movement.movementType,
        'quantity': movement.quantity,
        'unit': movement.unit,
        if (movement.reference != null) 'reference': movement.reference,
        if (movement.notes != null) 'notes': movement.notes,
        if (movement.fromLocation != null)
          'fromLocation': movement.fromLocation,
        if (movement.toLocation != null) 'toLocation': movement.toLocation,
      };
      final response = await _dio.post(
        '/farms/$farmId/inventory/movements',
        data: data,
      );
      return StockMovement.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Suppliers
  Future<List<Supplier>> fetchSuppliers(String farmId) async {
    try {
      final response = await _dio.get('/farms/$farmId/inventory/suppliers');
      final suppliers = response.data as List<dynamic>;
      return suppliers
          .map(
            (supplier) => Supplier.fromJson(supplier as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Supplier> createSupplier(String farmId, Supplier supplier) async {
    try {
      final data = {
        'name': supplier.name,
        'contact': supplier.contact,
        'email': supplier.email,
        'products': supplier.products,
      };
      final response = await _dio.post(
        '/farms/$farmId/inventory/suppliers',
        data: data,
      );
      return Supplier.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // Export Report
  Future<String> exportInventoryReport(String farmId, String format) async {
    try {
      // format: 'pdf', 'excel'
      final response = await _dio.get(
        '/farms/$farmId/inventory/export',
        queryParameters: {'format': format},
      );
      return response.data as String; // Returns file path or download URL
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Barcode Scan
  Future<InventoryItem?> getItemByBarcode(String farmId, String barcode) async {
    try {
      final response = await _dio.get(
        '/farms/$farmId/inventory/barcode/$barcode',
      );
      if (response.data == null) return null;
      return InventoryItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ErrorHandler.from(e);
    }
  }
}

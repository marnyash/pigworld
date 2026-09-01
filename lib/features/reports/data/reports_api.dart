import 'package:dio/dio.dart';
import 'package:proj/core/errors/error_handler.dart';
import 'package:proj/features/reports/domain/entities/report_metrics.dart';

/// API client for reports and analytics
class ReportsApi {
  ReportsApi(this._dio);

  final Dio _dio;

  // Get metrics for a date range
  Future<ReportMetrics> getMetrics(
    String farmId, {
    required String
    dateRange, // 'today', 'week', 'month', 'year', or ISO date range
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'dateRange': dateRange,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final response = await _dio.get(
        '/farms/$farmId/reports/metrics',
        queryParameters: params,
      );
      return ReportMetrics.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Export report
  Future<String> exportReport(
    String farmId, {
    required String
    reportType, // 'financial', 'herd', 'health', 'feed', 'breeding', 'inventory'
    required String format, // 'pdf', 'excel', 'csv'
    String? dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'format': format,
        if (dateRange != null) 'dateRange': dateRange,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final response = await _dio.get(
        '/farms/$farmId/reports/$reportType/export',
        queryParameters: params,
      );
      return response.data as String; // Returns file path or download URL
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Get revenue vs expenses data for chart
  Future<List<Map<String, dynamic>>> getRevenueVsExpensesData(
    String farmId, {
    required String dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'dateRange': dateRange,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final response = await _dio.get(
        '/farms/$farmId/reports/revenue-vs-expenses',
        queryParameters: params,
      );
      return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Get sales trend data
  Future<List<Map<String, dynamic>>> getSalesTrendData(
    String farmId, {
    required String dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'dateRange': dateRange,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final response = await _dio.get(
        '/farms/$farmId/reports/sales-trend',
        queryParameters: params,
      );
      return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Get feed consumption data
  Future<List<Map<String, dynamic>>> getFeedConsumptionData(
    String farmId, {
    required String dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'dateRange': dateRange,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final response = await _dio.get(
        '/farms/$farmId/reports/feed-consumption',
        queryParameters: params,
      );
      return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }

  // Get weight growth data
  Future<List<Map<String, dynamic>>> getWeightGrowthData(
    String farmId, {
    required String dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'dateRange': dateRange,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final response = await _dio.get(
        '/farms/$farmId/reports/weight-growth',
        queryParameters: params,
      );
      return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ErrorHandler.from(e);
    }
  }
}

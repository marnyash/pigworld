import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';
import 'package:proj/features/reports/data/reports_api.dart';
import 'package:proj/features/reports/data/reports_local_data_source.dart';
import 'package:proj/features/reports/domain/entities/report_metrics.dart';

// Local data source provider
final reportsLocalDataSourceProvider = Provider(
  (_) => ReportsLocalDataSource(),
);

// API provider
final reportsApiProvider = Provider(
  (ref) => ReportsApi(ref.watch(dioProvider)),
);

// Date range state
final selectedDateRangeProvider = StateProvider<String>((ref) => 'month');
final customStartDateProvider = StateProvider<DateTime?>((_) => null);
final customEndDateProvider = StateProvider<DateTime?>((_) => null);

// Report metrics provider
class ReportMetricsNotifier extends AsyncNotifier<ReportMetrics> {
  @override
  Future<ReportMetrics> build() async {
    final dateRange = ref.watch(selectedDateRangeProvider);
    final local = ref.watch(reportsLocalDataSourceProvider);
    return local.readMetrics(dateRange);
  }

  Future<void> fetchMetrics(String dateRange) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // In production, fetch from API
      // final api = ref.watch(reportsApiProvider);
      // final startDate = ref.watch(customStartDateProvider);
      // final endDate = ref.watch(customEndDateProvider);
      // final metrics = await api.getMetrics(
      //   farmId,
      //   dateRange: dateRange,
      //   startDate: startDate,
      //   endDate: endDate,
      // );
      // final local = ref.watch(reportsLocalDataSourceProvider);
      // await local.saveMetrics(dateRange, metrics);
      // return metrics;

      // For now, return mock data
      return ReportMetrics.defaults();
    });
  }
}

final reportMetricsProvider =
    AsyncNotifierProvider<ReportMetricsNotifier, ReportMetrics>(
      ReportMetricsNotifier.new,
    );

// Revenue vs Expenses chart data provider
final revenueVsExpensesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      dateRange,
    ) async {
      // Mock data - replace with API call in production
      return [
        {'label': 'Week 1', 'revenue': 45000, 'expenses': 28000},
        {'label': 'Week 2', 'revenue': 52000, 'expenses': 31000},
        {'label': 'Week 3', 'revenue': 48000, 'expenses': 29500},
        {'label': 'Week 4', 'revenue': 61000, 'expenses': 35000},
      ];
    });

// Sales trend chart data provider
final salesTrendProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      dateRange,
    ) async {
      // Mock data - replace with API call in production
      return [
        {'label': 'Jan', 'sales': 12},
        {'label': 'Feb', 'sales': 15},
        {'label': 'Mar', 'sales': 18},
        {'label': 'Apr', 'sales': 22},
        {'label': 'May', 'sales': 19},
        {'label': 'Jun', 'sales': 25},
      ];
    });

// Feed consumption chart data provider
final feedConsumptionProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      dateRange,
    ) async {
      // Mock data - replace with API call in production
      return [
        {'label': 'Grower Feed', 'value': 2400},
        {'label': 'Starter Feed', 'value': 1200},
        {'label': 'Finisher Feed', 'value': 1800},
        {'label': 'Special Feed', 'value': 600},
      ];
    });

// Weight growth chart data provider
final weightGrowthProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      dateRange,
    ) async {
      // Mock data - replace with API call in production
      return [
        {'week': 1, 'averageWeight': 5.2},
        {'week': 2, 'averageWeight': 8.5},
        {'week': 3, 'averageWeight': 12.8},
        {'week': 4, 'averageWeight': 18.3},
        {'week': 5, 'averageWeight': 25.6},
        {'week': 6, 'averageWeight': 34.2},
        {'week': 7, 'averageWeight': 45.8},
        {'week': 8, 'averageWeight': 58.5},
      ];
    });

// Vaccination completion chart data provider
final vaccinationCompletionProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      dateRange,
    ) async {
      // Mock data - replace with API call in production
      return [
        {'vaccine': 'ASFV', 'completion': 98},
        {'vaccine': 'Erysipelothrix', 'completion': 95},
        {'vaccine': 'Mycoplasma', 'completion': 92},
        {'vaccine': 'Porcine Parvovirus', 'completion': 100},
      ];
    });

// Export report
final exportReportProvider =
    FutureProvider.family<String, ({String type, String format})>((
      ref,
      params,
    ) async {
      // Mock implementation - replace with API call in production
      return 'report_${params.type}_${DateTime.now().millisecondsSinceEpoch}.${params.format}';
    });

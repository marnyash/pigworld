import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/features/auth/domain/entities/farm.dart';
import 'package:proj/features/auth/domain/entities/session.dart';
import 'package:proj/features/auth/domain/entities/user.dart';
import 'package:proj/features/auth/presentation/providers/auth_provider.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';
import 'package:proj/features/reports/data/reports_api.dart';
import 'package:proj/features/reports/domain/entities/report_metrics.dart';
import 'package:proj/features/reports/presentation/providers/reports_providers.dart';
import 'package:proj/features/sales/presentation/pages/sales_page.dart';
import 'package:proj/security/authorization/roles.dart';

void main() {
  testWidgets('sales page renders the farm sales dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SalesPage())),
    );

    expect(find.text('Sales'), findsAtLeastNWidgets(1));
    expect(find.text('Sales Overview'), findsOneWidget);
    expect(find.text("Today's Sales"), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('sales page reflects live farm metrics from the backend', (
    WidgetTester tester,
  ) async {
    final metrics = ReportMetrics(
      totalRevenue: 125000,
      totalExpenses: 42000,
      mortalityRate: 4.2,
      averageGrowth: 18.5,
      feedConsumption: 960,
      salesCount: 11,
      vaccinationCompletion: 92.5,
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 30),
    );
    final session = Session(
      accessToken: 'token',
      refreshToken: 'refresh',
      user: User(
        id: 'user-1',
        name: 'Farm Owner',
        email: 'owner@example.com',
        phone: '+254700000000',
        role: UserRole.farmOwner,
      ),
      farms: [
        Farm(
          id: 'farm-1',
          name: 'Alpha Farm',
          location: 'Nairobi',
          latitude: 0,
          longitude: 0,
          inviteCode: 'code',
          motherPigCount: 0,
          registeredPigletCount: 0,
          pregnantPigCount: 0,
          subscriptionPlan: 'Starter',
        ),
      ],
      selectedFarm: Farm(
        id: 'farm-1',
        name: 'Alpha Farm',
        location: 'Nairobi',
        latitude: 0,
        longitude: 0,
        inviteCode: 'code',
        motherPigCount: 0,
        registeredPigletCount: 0,
        pregnantPigCount: 0,
        subscriptionPlan: 'Starter',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(session)),
          reportsApiProvider.overrideWithValue(_FakeReportsApi(metrics)),
        ],
        child: const MaterialApp(home: SalesPage()),
      ),
    );
    await tester.pump();

    expect(find.text('KSh 125,000'), findsNWidgets(2));
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Monthly Revenue'), findsOneWidget);
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this.session);

  final Session session;

  @override
  AsyncValue<Session?> build() => AsyncData(session);
}

class _FakeReportsApi extends ReportsApi {
  _FakeReportsApi(this.metrics) : super(Dio());

  final ReportMetrics metrics;

  @override
  Future<ReportMetrics> getMetrics(
    String farmId, {
    required String dateRange,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return metrics;
  }
}

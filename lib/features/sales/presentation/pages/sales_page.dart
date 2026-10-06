import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/reports/presentation/providers/reports_providers.dart';
import '../../../../shared/components/bottom_navigation.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(reportMetricsProvider);
    final range = ref.watch(selectedDateRangeProvider);
    final hasFarm = ref.watch(authProvider).valueOrNull?.selectedFarm != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(reportMetricsProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            Card(
              color: AppColors.deepGreen,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Livestock sales',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.inverseText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This view reports animals marked sold. Customer orders and buyer records are managed in CRM.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inverseMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text('Period', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingSmall),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final option in const {
                    'today': 'Today',
                    'week': 'Week',
                    'month': 'Month',
                    'year': 'Year',
                  }.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(option.value),
                        selected: range == option.key,
                        onSelected: (_) {
                          ref.read(selectedDateRangeProvider.notifier).state =
                              option.key;
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            if (!hasFarm)
              const _SalesMessage(
                icon: Icons.agriculture_outlined,
                message: 'Select a farm to view its sales activity.',
              )
            else
              metrics.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => _SalesMessage(
                  icon: Icons.error_outline,
                  message: 'Could not load sales activity: $error',
                ),
                data: (data) => Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.pets_outlined),
                        ),
                        title: const Text('Animals marked sold'),
                        subtitle: Text(_periodLabel(range)),
                        trailing: Text(
                          '${data.salesCount}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    _SalesMessage(
                      icon: data.salesCount == 0
                          ? Icons.receipt_long_outlined
                          : Icons.info_outline,
                      message: data.salesCount == 0
                          ? 'No animals were marked sold during this period.'
                          : 'The backend does not yet store sale prices, payment status, or livestock invoices.',
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppDimensions.spacingLarge),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.crm),
              icon: const Icon(Icons.groups_outlined),
              label: const Text('Open customer orders in CRM'),
            ),
          ],
        ),
      ),
    );
  }

  static String _periodLabel(String range) => switch (range) {
    'today' => 'Today',
    'week' => 'This week',
    'year' => 'This year',
    _ => 'This month',
  };
}

class _SalesMessage extends StatelessWidget {
  const _SalesMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

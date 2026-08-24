import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../domain/entities/customer.dart';
import '../providers/crm_provider.dart';
import '../widgets/customer_card.dart';

class CrmPage extends ConsumerStatefulWidget {
  const CrmPage({super.key});

  @override
  ConsumerState<CrmPage> createState() => _CrmPageState();
}

class _CrmPageState extends ConsumerState<CrmPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final filter = ref.watch(crmFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.crmAddCustomer),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search customers…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) =>
                  ref.read(crmFilterProvider.notifier).setSearch(value),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding,
              ),
              children: [
                _StatusChip(
                  label: 'All',
                  selected: filter.status == null,
                  onSelected: () =>
                      ref.read(crmFilterProvider.notifier).setStatus(null),
                ),
                for (final status in CustomerStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spacingSmall,
                    ),
                    child: _StatusChip(
                      label: status.label,
                      selected: filter.status == status,
                      onSelected: () => ref
                          .read(crmFilterProvider.notifier)
                          .setStatus(status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No customers yet. Tap “Add customer” to create one.',
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(customersProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePadding,
                      0,
                      AppDimensions.pagePadding,
                      96,
                    ),
                    itemCount: customers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDimensions.spacingSmall),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () =>
                            context.push('${AppRoutes.crm}/${customer.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  error is ApiException
                      ? error.message
                      : 'Unable to load customers.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
    selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
  );
}

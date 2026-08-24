import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_interaction.dart';
import 'crm_providers.dart';

class CrmFilter {
  const CrmFilter({this.search, this.status, this.type});

  final String? search;
  final CustomerStatus? status;
  final CustomerType? type;

  CrmFilter copyWith({
    String? search,
    CustomerStatus? status,
    bool clearStatus = false,
  }) => CrmFilter(
    search: search ?? this.search,
    status: clearStatus ? null : (status ?? this.status),
    type: type,
  );
}

final crmFilterProvider = NotifierProvider<CrmFilterNotifier, CrmFilter>(
  CrmFilterNotifier.new,
);

class CrmFilterNotifier extends Notifier<CrmFilter> {
  @override
  CrmFilter build() => const CrmFilter();

  void setSearch(String value) => state = state.copyWith(search: value);

  void setStatus(CustomerStatus? value) =>
      state = state.copyWith(status: value, clearStatus: value == null);
}

final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) {
  final filter = ref.watch(crmFilterProvider);
  return ref
      .watch(getCustomersUseCaseProvider)
      .call(search: filter.search, status: filter.status, type: filter.type);
});

final customerProvider = FutureProvider.autoDispose.family<Customer, String>(
  (ref, id) => ref.watch(getCustomerUseCaseProvider).call(id),
);

final customerInteractionsProvider = FutureProvider.autoDispose
    .family<List<CustomerInteraction>, String>(
      (ref, customerId) =>
          ref.watch(getInteractionsUseCaseProvider).call(customerId),
    );

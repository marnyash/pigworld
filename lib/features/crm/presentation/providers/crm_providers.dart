import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasource/crm_remote_datasource.dart';
import '../../data/datasource/crm_remote_datasource_impl.dart';
import '../../data/repositories/crm_repository_impl.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../domain/usecases/add_interaction.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import '../../domain/usecases/get_customer.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/get_interactions.dart';
import '../../domain/usecases/update_customer.dart';

final crmRemoteDataSourceProvider = Provider<CrmRemoteDataSource>(
  (ref) => CrmRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final crmRepositoryProvider = Provider<CrmRepository>(
  (ref) => CrmRepositoryImpl(remote: ref.watch(crmRemoteDataSourceProvider)),
);

final getCustomersUseCaseProvider = Provider(
  (ref) => GetCustomers(ref.watch(crmRepositoryProvider)),
);
final getCustomerUseCaseProvider = Provider(
  (ref) => GetCustomer(ref.watch(crmRepositoryProvider)),
);
final createCustomerUseCaseProvider = Provider(
  (ref) => CreateCustomer(ref.watch(crmRepositoryProvider)),
);
final updateCustomerUseCaseProvider = Provider(
  (ref) => UpdateCustomer(ref.watch(crmRepositoryProvider)),
);
final deleteCustomerUseCaseProvider = Provider(
  (ref) => DeleteCustomer(ref.watch(crmRepositoryProvider)),
);
final getInteractionsUseCaseProvider = Provider(
  (ref) => GetInteractions(ref.watch(crmRepositoryProvider)),
);
final addInteractionUseCaseProvider = Provider(
  (ref) => AddInteraction(ref.watch(crmRepositoryProvider)),
);

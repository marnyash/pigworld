import '../entities/customer.dart';
import '../repositories/crm_repository.dart';

class GetCustomers {
  const GetCustomers(this.repository);
  final CrmRepository repository;
  Future<List<Customer>> call({
    String? search,
    CustomerStatus? status,
    CustomerType? type,
  }) => repository.getCustomers(search: search, status: status, type: type);
}

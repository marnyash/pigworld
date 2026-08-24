import '../entities/customer.dart';
import '../repositories/crm_repository.dart';

class GetCustomer {
  const GetCustomer(this.repository);
  final CrmRepository repository;
  Future<Customer> call(String id) => repository.getCustomer(id);
}

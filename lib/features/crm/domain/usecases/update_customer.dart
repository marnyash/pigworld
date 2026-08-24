import '../entities/customer.dart';
import '../repositories/crm_repository.dart';

class UpdateCustomer {
  const UpdateCustomer(this.repository);
  final CrmRepository repository;
  Future<Customer> call(Customer customer) =>
      repository.updateCustomer(customer);
}

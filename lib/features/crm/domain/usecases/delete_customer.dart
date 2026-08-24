import '../repositories/crm_repository.dart';

class DeleteCustomer {
  const DeleteCustomer(this.repository);
  final CrmRepository repository;
  Future<void> call(String id) => repository.deleteCustomer(id);
}

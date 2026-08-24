import '../entities/customer.dart';
import '../repositories/crm_repository.dart';

class CreateCustomer {
  const CreateCustomer(this.repository);
  final CrmRepository repository;

  Future<Customer> call({
    required String farmId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? address,
    CustomerType type = CustomerType.lead,
    CustomerStatus status = CustomerStatus.new_,
    String? notes,
  }) => repository.createCustomer(
    farmId: farmId,
    name: name,
    email: email,
    phone: phone,
    company: company,
    address: address,
    type: type,
    status: status,
    notes: notes,
  );
}

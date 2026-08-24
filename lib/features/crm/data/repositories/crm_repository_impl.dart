import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_interaction.dart';
import '../../domain/repositories/crm_repository.dart';
import '../datasource/crm_remote_datasource.dart';
import '../models/customer_model.dart';

class CrmRepositoryImpl implements CrmRepository {
  const CrmRepositoryImpl({required this.remote});

  final CrmRemoteDataSource remote;

  @override
  Future<List<Customer>> getCustomers({
    String? search,
    CustomerStatus? status,
    CustomerType? type,
  }) => remote.getCustomers(search: search, status: status, type: type);

  @override
  Future<Customer> getCustomer(String id) => remote.getCustomer(id);

  @override
  Future<Customer> createCustomer({
    required String farmId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? address,
    CustomerType type = CustomerType.lead,
    CustomerStatus status = CustomerStatus.new_,
    String? notes,
  }) {
    final model = CustomerModel(
      id: '',
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
    return remote.createCustomer(farmId, model.toJson());
  }

  @override
  Future<Customer> updateCustomer(Customer customer) {
    final model = CustomerModel(
      id: customer.id,
      farmId: customer.farmId,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      company: customer.company,
      address: customer.address,
      type: customer.type,
      status: customer.status,
      notes: customer.notes,
    );
    return remote.updateCustomer(customer.id, model.toJson());
  }

  @override
  Future<void> deleteCustomer(String id) => remote.deleteCustomer(id);

  @override
  Future<List<CustomerInteraction>> getInteractions(String customerId) =>
      remote.getInteractions(customerId);

  @override
  Future<CustomerInteraction> addInteraction({
    required String customerId,
    required InteractionType type,
    String? notes,
  }) => remote.addInteraction(customerId, {'type': type.name, 'notes': notes});
}

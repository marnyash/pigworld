import '../entities/customer.dart';
import '../entities/customer_interaction.dart';

abstract interface class CrmRepository {
  Future<List<Customer>> getCustomers({
    String? search,
    CustomerStatus? status,
    CustomerType? type,
  });
  Future<Customer> getCustomer(String id);
  Future<Customer> createCustomer({
    required String farmId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? address,
    CustomerType type,
    CustomerStatus status,
    String? notes,
  });
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerInteraction>> getInteractions(String customerId);
  Future<CustomerInteraction> addInteraction({
    required String customerId,
    required InteractionType type,
    String? notes,
  });
}

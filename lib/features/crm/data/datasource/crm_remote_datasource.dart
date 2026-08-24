import '../../domain/entities/customer.dart';
import '../models/customer_interaction_model.dart';
import '../models/customer_model.dart';

abstract interface class CrmRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({
    String? search,
    CustomerStatus? status,
    CustomerType? type,
  });
  Future<CustomerModel> getCustomer(String id);
  Future<CustomerModel> createCustomer(
    String farmId,
    Map<String, dynamic> data,
  );
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerInteractionModel>> getInteractions(String customerId);
  Future<CustomerInteractionModel> addInteraction(
    String customerId,
    Map<String, dynamic> data,
  );
}

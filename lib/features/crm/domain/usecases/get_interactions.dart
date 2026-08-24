import '../entities/customer_interaction.dart';
import '../repositories/crm_repository.dart';

class GetInteractions {
  const GetInteractions(this.repository);
  final CrmRepository repository;
  Future<List<CustomerInteraction>> call(String customerId) =>
      repository.getInteractions(customerId);
}

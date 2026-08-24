import '../entities/customer_interaction.dart';
import '../repositories/crm_repository.dart';

class AddInteraction {
  const AddInteraction(this.repository);
  final CrmRepository repository;
  Future<CustomerInteraction> call({
    required String customerId,
    required InteractionType type,
    String? notes,
  }) => repository.addInteraction(
    customerId: customerId,
    type: type,
    notes: notes,
  );
}

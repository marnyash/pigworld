import '../../domain/entities/customer_interaction.dart';

class CustomerInteractionModel extends CustomerInteraction {
  const CustomerInteractionModel({
    required super.id,
    required super.customerId,
    required super.type,
    required super.occurredAt,
    super.notes,
  });

  factory CustomerInteractionModel.fromJson(Map<String, dynamic> json) =>
      CustomerInteractionModel(
        id: '${json['id']}',
        customerId: '${json['customer_id']}',
        type: InteractionType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => InteractionType.note,
        ),
        occurredAt:
            DateTime.tryParse('${json['occurred_at']}') ?? DateTime.now(),
        notes: json['notes'] as String?,
      );
}

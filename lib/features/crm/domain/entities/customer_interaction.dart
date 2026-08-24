enum InteractionType { call, email, visit, meeting, note }

extension InteractionTypeX on InteractionType {
  String get label => switch (this) {
    InteractionType.call => 'Call',
    InteractionType.email => 'Email',
    InteractionType.visit => 'Visit',
    InteractionType.meeting => 'Meeting',
    InteractionType.note => 'Note',
  };
}

class CustomerInteraction {
  const CustomerInteraction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.occurredAt,
    this.notes,
  });

  final String id;
  final String customerId;
  final InteractionType type;
  final DateTime occurredAt;
  final String? notes;
}

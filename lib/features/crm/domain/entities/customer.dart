enum CustomerType { lead, buyer, supplier }

enum CustomerStatus { new_, contacted, qualified, won, lost }

extension CustomerTypeX on CustomerType {
  String get label => switch (this) {
    CustomerType.lead => 'Lead',
    CustomerType.buyer => 'Buyer',
    CustomerType.supplier => 'Supplier',
  };
}

extension CustomerStatusX on CustomerStatus {
  String get label => switch (this) {
    CustomerStatus.new_ => 'New',
    CustomerStatus.contacted => 'Contacted',
    CustomerStatus.qualified => 'Qualified',
    CustomerStatus.won => 'Won',
    CustomerStatus.lost => 'Lost',
  };
}

class Customer {
  const Customer({
    required this.id,
    required this.farmId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.address,
    this.type = CustomerType.lead,
    this.status = CustomerStatus.new_,
    this.notes,
  });

  final String id;
  final String farmId;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String? address;
  final CustomerType type;
  final CustomerStatus status;
  final String? notes;

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? company,
    String? address,
    CustomerType? type,
    CustomerStatus? status,
    String? notes,
  }) => Customer(
    id: id,
    farmId: farmId,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    company: company ?? this.company,
    address: address ?? this.address,
    type: type ?? this.type,
    status: status ?? this.status,
    notes: notes ?? this.notes,
  );
}

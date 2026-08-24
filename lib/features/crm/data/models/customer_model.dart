import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.farmId,
    required super.name,
    super.email,
    super.phone,
    super.company,
    super.address,
    super.type,
    super.status,
    super.notes,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: '${json['id']}',
    farmId: '${json['farm_id']}',
    name: '${json['name'] ?? ''}',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    company: json['company'] as String?,
    address: json['address'] as String?,
    type: CustomerType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => CustomerType.lead,
    ),
    status: CustomerStatus.values.firstWhere(
      (s) =>
          s.name == json['status'] ||
          (json['status'] == 'new' && s == CustomerStatus.new_),
      orElse: () => CustomerStatus.new_,
    ),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'company': company,
    'address': address,
    'type': type.name,
    'status': status == CustomerStatus.new_ ? 'new' : status.name,
    'notes': notes,
  };
}

class Animal {
  const Animal({
    required this.id,
    required this.tag,
    required this.type,
    required this.sex,
    required this.status,
    this.birthDate,
    this.notes,
  });

  final String id;
  final String tag;
  final String type;
  final String sex;
  final String status;
  final DateTime? birthDate;
  final String? notes;

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
    id: '${json['id']}',
    tag: '${json['tag'] ?? ''}',
    type: '${json['type'] ?? ''}',
    sex: '${json['sex'] ?? ''}',
    status: '${json['status'] ?? 'active'}',
    birthDate: json['birth_date'] == null
        ? null
        : DateTime.tryParse('${json['birth_date']}'),
    notes: json['notes'] as String?,
  );
}

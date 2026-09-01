import '../../domain/entities/farm.dart';

class FarmModel extends Farm {
  const FarmModel({
    required super.id,
    required super.name,
    super.location,
    super.inviteCode,
    super.motherPigCount,
    super.registeredPigletCount,
    super.pregnantPigCount,
    super.subscriptionPlan,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    final pigletGroups = json['piglet_groups'] as List<dynamic>? ?? const [];
    var registeredPigletCount = 0;
    for (final group in pigletGroups) {
      if (group is! Map) continue;
      final count = group['count'];
      if (count is num) registeredPigletCount += count.toInt();
    }
    return FarmModel(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      location: json['location'] as String?,
      inviteCode: json['invite_code'] as String?,
      motherPigCount: (json['mother_pig_count'] as num?)?.toInt() ?? 0,
      registeredPigletCount: registeredPigletCount,
      pregnantPigCount: (json['pregnant_pig_count'] as num?)?.toInt() ?? 0,
      subscriptionPlan: json['subscription_plan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'invite_code': inviteCode,
    'mother_pig_count': motherPigCount,
    'piglet_groups': [
      if (registeredPigletCount > 0) {'count': registeredPigletCount},
    ],
    'pregnant_pig_count': pregnantPigCount,
    'subscription_plan': subscriptionPlan,
  };
}

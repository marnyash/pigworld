import '../../domain/entities/farm.dart';

class FarmModel extends Farm {
  const FarmModel({
    required super.id,
    required super.name,
    super.location,
    super.inviteCode,
    super.motherPigCount,
    super.subscriptionPlan,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
    id: '${json['id']}',
    name: '${json['name'] ?? ''}',
    location: json['location'] as String?,
    inviteCode: json['invite_code'] as String?,
    motherPigCount: (json['mother_pig_count'] as num?)?.toInt() ?? 0,
    subscriptionPlan: json['subscription_plan'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'invite_code': inviteCode,
    'mother_pig_count': motherPigCount,
    'subscription_plan': subscriptionPlan,
  };
}

import '../../domain/entities/farm.dart';

class FarmModel extends Farm {
  const FarmModel({required super.id, required super.name, super.location});

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
        id: '${json['id']}',
        name: '${json['name'] ?? ''}',
        location: json['location'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'location': location};
}

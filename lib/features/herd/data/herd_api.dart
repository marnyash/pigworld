import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../domain/entities/animal.dart';

class HerdApi {
  HerdApi(this._dio);

  final Dio _dio;

  Future<List<Animal>> fetchAnimals(String farmId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/farms/$farmId/animals',
      );
      final data = response.data?['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => Animal.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<Animal> createSow({
    required String farmId,
    required String tag,
    DateTime? birthDate,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/farms/$farmId/animals',
        data: {
          'tag': tag,
          'type': 'sow',
          'sex': 'female',
          if (birthDate != null)
            'birth_date': birthDate.toIso8601String().split('T').first,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      return Animal.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }
}

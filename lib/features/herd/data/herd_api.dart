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
          'birth_date': ?birthDate?.toIso8601String().split('T').first,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      return Animal.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<Animal> fetchAnimal({
    required String farmId,
    required String animalId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/farms/$farmId/animals/$animalId',
      );
      return Animal.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<Animal> updateAnimal({
    required String farmId,
    required String animalId,
    String? tag,
    String? status,
    DateTime? birthDate,
    String? notes,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/farms/$farmId/animals/$animalId',
        data: {
          'tag': tag?.trim(),
          'status': status,
          'birth_date': birthDate?.toIso8601String().split('T').first,
          'notes': notes?.trim(),
        },
      );
      return Animal.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<Animal> archiveAnimal({
    required String farmId,
    required String animalId,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/farms/$farmId/animals/$animalId',
      );
      return Animal.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }
}

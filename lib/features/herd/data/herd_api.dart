import 'dart:typed_data';

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
    double? weightKg,
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
          if (weightKg != null) 'weight_kg': weightKg,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      return Animal.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<Animal> createAnimal({
    required String farmId,
    required String tag,
    required String type,
    required String sex,
    DateTime? birthDate,
    double? weightKg,
    String? notes,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final data = {
        'tag': tag,
        'type': type,
        'sex': sex,
        'birth_date': ?birthDate?.toIso8601String().split('T').first,
        if (weightKg != null) 'weight_kg': weightKg,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };
      final response = imageBytes == null
          ? await _dio.post<Map<String, dynamic>>(
              '/farms/$farmId/animals',
              data: data,
            )
          : await _dio.post<Map<String, dynamic>>(
              '/farms/$farmId/animals',
              data: FormData.fromMap({
                ...data,
                'image': MultipartFile.fromBytes(
                  imageBytes,
                  filename: imageName ?? 'animal.jpg',
                ),
              }),
              options: Options(contentType: 'multipart/form-data'),
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
    double? weightKg,
    String? notes,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final data = {
        'tag': tag?.trim(),
        'status': status,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'weight_kg': weightKg,
        'notes': notes?.trim(),
      };
      final response = imageBytes == null
          ? await _dio.patch<Map<String, dynamic>>(
              '/farms/$farmId/animals/$animalId',
              data: data,
            )
          : await _dio.post<Map<String, dynamic>>(
              '/farms/$farmId/animals/$animalId',
              data: FormData.fromMap({
                ...data,
                '_method': 'PATCH',
                'image': MultipartFile.fromBytes(
                  imageBytes,
                  filename: imageName ?? 'animal.jpg',
                ),
              }),
              options: Options(contentType: 'multipart/form-data'),
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

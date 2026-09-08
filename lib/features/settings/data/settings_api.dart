import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';

/// API calls for user settings management.
class SettingsApi {
  SettingsApi(this._dio);

  final Dio _dio;

  Future<void> updateDisplayName(String name) async {
    try {
      await _dio.patch('/auth/profile', data: {'name': name});
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<void> renameFarm({
    required String farmId,
    required String name,
  }) async {
    try {
      await _dio.patch('/farms/$farmId', data: {'name': name});
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  // Profile updates
  Future<void> updateProfile({
    required String farmId,
    String? farmName,
    String? farmLocation,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (farmName != null) data['farm_name'] = farmName;
      if (farmLocation != null) data['location'] = farmLocation;
      if (phoneNumber != null) data['phone'] = phoneNumber;
      if (email != null) data['email'] = email;

      await _dio.patch('/farms/$farmId', data: data);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  // Export data
  Future<String> exportData({
    required String farmId,
    required String format, // 'pdf', 'excel'
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/farms/$farmId/export',
        queryParameters: {'format': format},
      );
      return response.data?['download_url'] as String? ?? '';
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  // Restore backup
  Future<void> restoreBackup({
    required String farmId,
    required String backupId,
  }) async {
    try {
      await _dio.post('/farms/$farmId/backups/$backupId/restore');
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }
}

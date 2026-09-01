import 'package:dio/dio.dart';

import '../../../core/errors/error_handler.dart';

class FarmNotification {
  const FarmNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.severity,
    required this.createdAt,
    this.readAt,
    this.actionRoute,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String severity;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionRoute;

  bool get isRead => readAt != null;

  factory FarmNotification.fromJson(Map<String, dynamic> json) =>
      FarmNotification(
        id: '${json['id']}',
        type: '${json['type'] ?? 'general'}',
        title: '${json['title'] ?? ''}',
        body: '${json['body'] ?? ''}',
        severity: '${json['severity'] ?? 'info'}',
        createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
        readAt: json['read_at'] == null
            ? null
            : DateTime.tryParse('${json['read_at']}'),
        actionRoute: json['action_route'] as String?,
      );
}

class NotificationsApi {
  NotificationsApi(this._dio);
  final Dio _dio;

  Future<List<FarmNotification>> fetch(String farmId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/farms/$farmId/notifications',
      );
      final data = response.data?['data'] as List<dynamic>? ?? [];
      return data
          .map(
            (item) => FarmNotification.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<FarmNotification> markAsRead({
    required String farmId,
    required String notificationId,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/farms/$farmId/notifications/$notificationId/read',
      );
      return FarmNotification.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }
}

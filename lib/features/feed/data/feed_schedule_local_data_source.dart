import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FeedScheduleLocalDataSource {
  FeedScheduleLocalDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const defaults = <String, bool>{
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
  };

  Future<Map<String, bool>> read({
    required String userId,
    required String farmId,
  }) async {
    try {
      final raw = await _storage.read(key: _key(userId, farmId));
      if (raw == null) return defaults;
      final stored = jsonDecode(raw) as Map<String, dynamic>;
      if (stored['date'] != _today()) return defaults;
      final values = Map<String, dynamic>.from(
        stored['completed'] as Map<dynamic, dynamic>? ?? const {},
      );
      return {
        for (final entry in defaults.entries)
          entry.key: values[entry.key] as bool? ?? false,
      };
    } on Object {
      return defaults;
    }
  }

  Future<void> write({
    required String userId,
    required String farmId,
    required Map<String, bool> completed,
  }) => _storage.write(
    key: _key(userId, farmId),
    value: jsonEncode({'date': _today(), 'completed': completed}),
  );

  Future<void> clearUser(String userId) async {
    final prefix = 'feed.schedule.${Uri.encodeComponent(userId)}.';
    final storedValues = await _storage.readAll();
    for (final key in storedValues.keys.where(
      (key) => key.startsWith(prefix),
    )) {
      await _storage.delete(key: key);
    }
  }

  String _key(String userId, String farmId) =>
      'feed.schedule.${Uri.encodeComponent(userId)}.${Uri.encodeComponent(farmId)}';

  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

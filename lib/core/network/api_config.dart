abstract final class ApiConfig {
  // Override per environment: --dart-define=API_BASE_URL=https://api.pigworld.app/api/v1
  // 10.0.2.2 is the Android emulator's alias for the host machine, used as the local dev default.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}

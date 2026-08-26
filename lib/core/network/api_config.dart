abstract final class ApiConfig {
  // Override per environment: --dart-define=API_BASE_URL=https://api.pigworld.app/api/v1
  // Laravel's local development server runs on port 8000. Android emulators must
  // use 10.0.2.2 instead of localhost so the request reaches the host machine.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}

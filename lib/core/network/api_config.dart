import 'api_origin.dart';

abstract final class ApiConfig {
  // Override per environment: --dart-define=API_BASE_URL=https://api.pigworld.app/api/v1
  // The local Compose stack exposes Nginx on port 80. Linux and iOS use
  // localhost; Android emulators use 10.0.2.2 to reach the host.
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    return configured.isNotEmpty ? configured : '${localApiOrigin()}/api/v1';
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}

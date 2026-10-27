import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  // Override per environment with --dart-define=API_BASE_URL=...
  static const productionBaseUrl = 'https://api.pigworldsmart.com/api/v1';

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    return validateBaseUrl(
      configured.isNotEmpty ? configured : productionBaseUrl,
    );
  }

  static String validateBaseUrl(String baseUrl, {bool? requireHttps}) {
    final normalized = baseUrl.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        uri.host.isEmpty ||
        !{'http', 'https'}.contains(uri.scheme.toLowerCase()) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException(
        'API base URL must be an absolute HTTP(S) URL without credentials, query, or fragment.',
      );
    }

    if ((requireHttps ?? kReleaseMode) && uri.scheme.toLowerCase() != 'https') {
      throw const FormatException(
        'API base URL must use HTTPS in release builds.',
      );
    }

    return normalized;
  }

  static void validateRequestUri(Uri uri, {bool? requireHttps}) {
    if (uri.host.isEmpty ||
        !{'http', 'https'}.contains(uri.scheme.toLowerCase()) ||
        uri.userInfo.isNotEmpty ||
        ((requireHttps ?? kReleaseMode) &&
            uri.scheme.toLowerCase() != 'https')) {
      throw const FormatException(
        'API requests must use HTTPS in release builds.',
      );
    }
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}

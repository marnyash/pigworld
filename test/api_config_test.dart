import 'package:flutter_test/flutter_test.dart';
import 'package:proj/core/network/api_config.dart';

void main() {
  group('ApiConfig.validateBaseUrl', () {
    test('accepts HTTPS API base URLs', () {
      expect(
        ApiConfig.validateBaseUrl('https://api.example.com/api/v1'),
        'https://api.example.com/api/v1',
      );
    });

    test('allows HTTP only when HTTPS is not required', () {
      expect(
        ApiConfig.validateBaseUrl(
          'http://10.0.2.2:8000/api/v1',
          requireHttps: false,
        ),
        'http://10.0.2.2:8000/api/v1',
      );
      expect(
        () => ApiConfig.validateBaseUrl(
          'http://api.example.com/api/v1',
          requireHttps: true,
        ),
        throwsFormatException,
      );
    });

    test(
      'rejects invalid schemes, credentials, query strings, and fragments',
      () {
        for (final url in [
          'ftp://api.example.com/api',
          'https://user:password@api.example.com/api',
          'https://api.example.com/api?token=secret',
          'https://api.example.com/api#fragment',
          'not a URL',
        ]) {
          expect(
            () => ApiConfig.validateBaseUrl(url),
            throwsFormatException,
            reason: 'Rejected $url',
          );
        }
      },
    );
  });

  group('ApiConfig.validateRequestUri', () {
    test('rejects cleartext requests when HTTPS is required', () {
      expect(
        () => ApiConfig.validateRequestUri(
          Uri.parse('http://api.example.com/api/v1/login'),
          requireHttps: true,
        ),
        throwsFormatException,
      );
      expect(
        () => ApiConfig.validateRequestUri(
          Uri.parse('https://api.example.com/api/v1/login'),
          requireHttps: true,
        ),
        returnsNormally,
      );
    });

    test('rejects unsupported schemes and credential-bearing requests', () {
      for (final url in [
        'ftp://api.example.com/api/v1',
        'https://user:password@api.example.com/api/v1',
      ]) {
        expect(
          () => ApiConfig.validateRequestUri(Uri.parse(url)),
          throwsFormatException,
          reason: 'Rejected $url',
        );
      }
    });
  });
}

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proj/core/network/auth_interceptor.dart';
import 'package:proj/security/authentication/auth_service.dart';

void main() {
  test('attaches the stored access token as a bearer token', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.interceptors.add(
      AuthInterceptor(
        authService: _FakeAuthService(),
        onSessionExpired: () async {},
        baseUrl: () => dio.options.baseUrl,
      ),
    );
    dio.httpClientAdapter = adapter;

    await dio.get<void>('/subscription-plans');

    expect(adapter.authorization?.startsWith('Bearer '), isTrue);
    expect(adapter.authorization?.endsWith('for-test'), isTrue);
    dio.close(force: true);
  });
}

class _FakeAuthService extends AuthService {
  @override
  Future<String?> readAccessToken() async => 'access-token-for-test';
}

class _RecordingAdapter implements HttpClientAdapter {
  String? authorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorization = options.headers['Authorization'] as String?;
    return ResponseBody.fromString(
      '{"data":[]}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

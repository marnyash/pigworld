import 'package:dio/dio.dart';

import '../../security/authentication/auth_service.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

abstract final class DioClient {
  static Dio create({
    required AuthService authService,
    required Future<void> Function() onSessionExpired,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(
        authService: authService,
        onSessionExpired: onSessionExpired,
      ),
      LoggingInterceptor(),
    ]);
    return dio;
  }
}

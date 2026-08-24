import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs request/response line info in debug builds only; headers and bodies are never logged since they may carry tokens or PII.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) debugPrint('--> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}',
      );
    }
    handler.next(err);
  }
}

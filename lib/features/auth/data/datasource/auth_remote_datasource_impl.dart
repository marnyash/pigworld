import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponse> login(LoginRequest request) =>
      _postForSession('/auth/login', request.toJson());

  @override
  Future<LoginResponse> register(RegisterRequest request) =>
      _postForSession('/auth/register', request.toJson());

  @override
  Future<LoginResponse> refresh(String refreshToken) =>
      _postForSession('/auth/refresh', {'refresh_token': refreshToken});

  @override
  Future<void> logout(String accessToken) async {
    try {
      await _dio.post<void>('/auth/logout');
    } on DioException {
      // Best-effort: the local session is cleared by the caller regardless of server-side revocation.
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post<void>('/auth/forgot-password', data: {'email': email});
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }

  Future<LoginResponse> _postForSession(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return LoginResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ErrorHandler.from(error);
    }
  }
}

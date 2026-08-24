import '../models/login_request.dart';
import '../models/login_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> refresh(String refreshToken);
  Future<void> logout(String accessToken);
  Future<void> forgotPassword(String email);
}

class UnconfiguredAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> login(LoginRequest request) => throw UnimplementedError('Connect the Laravel API in the network layer.');
  @override
  Future<LoginResponse> refresh(String refreshToken) => throw UnimplementedError('Connect the Laravel API in the network layer.');
  @override
  Future<void> logout(String accessToken) async {}
  @override
  Future<void> forgotPassword(String email) async {}
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinAuth {
  PinAuth({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();
  static const _pinKey = 'auth.pin';
  final FlutterSecureStorage _storage;

  Future<void> setPin(String pin) => _storage.write(key: _pinKey, value: pin);
  Future<bool> verify(String pin) async => (await _storage.read(key: _pinKey)) == pin;
  Future<void> clear() => _storage.delete(key: _pinKey);
}

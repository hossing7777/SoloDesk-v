import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// PIN (hashed, kept in secure storage) + optional biometric unlock.
class AuthService {
  AuthService([LocalAuthentication? auth, FlutterSecureStorage? storage])
      : _auth = auth ?? LocalAuthentication(),
        _storage = storage ?? const FlutterSecureStorage();

  final LocalAuthentication _auth;
  final FlutterSecureStorage _storage;
  static const String _pinKey = 'pin_hash';

  String _hash(String pin) => sha256.convert(utf8.encode('solodesk:$pin')).toString();

  Future<void> setPin(String pin) => _storage.write(key: _pinKey, value: _hash(pin));

  Future<bool> checkPin(String pin) async => (await _storage.read(key: _pinKey)) == _hash(pin);

  Future<void> clearPin() => _storage.delete(key: _pinKey);

  Future<bool> biometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }
}

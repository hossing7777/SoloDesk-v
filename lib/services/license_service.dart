import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solodesk/utils/license_algo.dart';

/// Offline license validation + secure storage of the activated key.
class LicenseService {
  LicenseService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _keyName = 'license_key';

  /// The signing secret (set with --dart-define=LICENSE_SECRET=...).
  static String get secret {
    const fromEnv = String.fromEnvironment('LICENSE_SECRET');
    return fromEnv.isEmpty ? kDefaultLicenseSecret : fromEnv;
  }

  static bool validate(String key) => LicenseAlgo.validate(key, secret);

  Future<bool> isActivated() async {
    try {
      final stored = await _storage.read(key: _keyName);
      return stored != null && validate(stored);
    } catch (_) {
      return false;
    }
  }

  /// Returns true (and stores the key) if [key] is valid.
  Future<bool> activate(String key) async {
    if (!validate(key)) return false;
    await _storage.write(key: _keyName, value: key.trim().toUpperCase());
    return true;
  }
}

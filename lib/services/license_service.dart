import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solodesk/utils/license_algo.dart';

/// Result of validating a license key.
enum LicenseStatus { free, pro }

/// Offline license validation + secure storage of the activated key.
///
/// Validation order:
///   1. Master License Key (one fixed key, no secret involved).
///   2. HMAC per-customer key (kept as a secondary validator; see
///      lib/utils/license_algo.dart and tools/generate_license.dart).
///
/// SECURITY LIMITATION: the master key is rebuilt at runtime from XOR-encoded
/// pieces so it does not appear as one plain string in the source or as a
/// clean string literal in the compiled app. This only stops casual copying.
/// A determined reverse engineer can still recover it, because validation is
/// fully offline. If the key leaks, change the pieces below and rebuild.
class LicenseService {
  LicenseService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _keyName = 'license_key';

  // --- Master key pieces (XOR 0x5A encoded char codes; see _decode) ---------
  static const int _mask = 0x5A;
  static const List<int> _pieceOne = [0, 10, 25, 31, 25, 20, 3, 25];
  static const List<int> _pieceTwo = [16, 10, 31, 23, 28, 105, 24, 2];
  static const List<int> _pieceThree = [111, 98, 31, 17, 17, 11, 14, 28];

  static String _decode(List<int> codes) =>
      String.fromCharCodes(codes.map((c) => c ^ _mask));

  /// Master key without dashes, e.g. SOLOXXXXXXXXXXXXXXXXXXXXXXXX.
  static String get _master =>
      'SOLO${_decode(_pieceOne)}${_decode(_pieceTwo)}${_decode(_pieceThree)}';

  /// Trim, uppercase and drop dashes/spaces so formatting never matters.
  static String _normalize(String input) =>
      input.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  /// Secret for the optional HMAC keys (set with --dart-define=LICENSE_SECRET=...).
  /// NOT used by the master key.
  static String get secret {
    const fromEnv = String.fromEnvironment('LICENSE_SECRET');
    return fromEnv.isEmpty ? kDefaultLicenseSecret : fromEnv;
  }

  /// Master key first, then the HMAC fallback.
  static LicenseStatus statusOf(String key) {
    if (_normalize(key) == _master) return LicenseStatus.pro;
    if (LicenseAlgo.validate(key, secret)) return LicenseStatus.pro;
    return LicenseStatus.free;
  }

  static bool validate(String key) => statusOf(key) == LicenseStatus.pro;

  Future<bool> isActivated() async {
    try {
      final stored = await _storage.read(key: _keyName);
      return stored != null && validate(stored);
    } catch (_) {
      return false;
    }
  }

  /// Returns true (and stores the key) if [key] unlocks Pro.
  Future<bool> activate(String key) async {
    if (!validate(key)) return false;
    await _storage.write(key: _keyName, value: key.trim().toUpperCase());
    return true;
  }
}

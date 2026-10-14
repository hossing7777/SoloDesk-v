import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Development secret. Override for production builds with
/// `--dart-define=LICENSE_SECRET=<your secret>` (see README).
const String kDefaultLicenseSecret = 'CHANGE-ME-SOLODESK-SECRET';

/// Pure-Dart license algorithm (no Flutter imports) so that the seller CLI in
/// tools/ can share it. Key format: SOLO-XXXXXXXX-YYYYYYYY where the second
/// block is the first 8 hex chars of HMAC-SHA256(secret, firstBlock).
class LicenseAlgo {
  LicenseAlgo._();

  static final RegExp _format = RegExp(r'^SOLO-[A-Z0-9]{8}-[0-9A-F]{8}$');

  static String sign(String payload, String secret) {
    final mac = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(payload));
    return mac.toString().substring(0, 8).toUpperCase();
  }

  static String build(String payload, String secret) =>
      'SOLO-$payload-${sign(payload, secret)}';

  static bool validate(String key, String secret) {
    final k = key.trim().toUpperCase();
    if (!_format.hasMatch(k)) return false;
    final parts = k.split('-');
    return sign(parts[1], secret) == parts[2];
  }
}

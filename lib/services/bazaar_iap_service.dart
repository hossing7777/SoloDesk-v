import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// RSA public key from the Cafe Bazaar developer panel
/// (برنامه‌ها → your app → پرداخت درون‌برنامه‌ای → کلید RSA). It is a PUBLIC key,
/// so it is safe to commit. Until you replace it, purchases are disabled.
const String kBazaarRsaKey = 'MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCt2ARzSDtfl9/SmLRBDyduQs0Fg8GIlF/4V1m+R3N0ODyhZlKyqjkwAd5vRHhGUZcG7eA8Lx4j5KEZh/9kVU7vQzMJUNygYbHGxdto7FiZ7X3Bg/s8PhYycxSk+vACG87TP+mMTtQvA1KC6gnE/3vPa9lyqTBjJP8xsDurdt13wpN9di/6e1KaD70qKlmpVdUhqw2gg/hh7Lla3JMfiNwWGdhX5Fi9XHR4hyGkB4MCAwEAAQ==';

/// Cafe Bazaar in-app billing (Poolakey) for the one-time "Pro" product.
///
/// The Pro flag is cached in secure storage so the app works offline after the
/// first successful check. A local flag can be tampered with on a rooted
/// device; it is a convenience cache, not strong DRM.
class BazaarIapService {
  BazaarIapService._();

  static final BazaarIapService instance = BazaarIapService._();

  /// Product id registered in the Cafe Bazaar panel.
  static const String proSku = 'solodesk_pro';
  static const String _storeKey = 'bazaar_is_pro';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _connected = false;
  Future<bool>? _connecting;

  /// True when the last [purchasePro] call ended because the user cancelled.
  bool lastPurchaseCancelled = false;

  /// Cached Pro state (works offline).
  Future<bool> readStoredPro() async {
    try {
      return (await _storage.read(key: _storeKey)) == '1';
    } catch (_) {
      return false;
    }
  }

  Future<void> _storePro(bool value) async {
    try {
      await _storage.write(key: _storeKey, value: value ? '1' : '0');
    } catch (_) {
      // Caching is best-effort.
    }
  }

  /// Connects to the Cafe Bazaar app. Safe to call repeatedly.
  Future<void> init() async {
    await _connect();
  }

  Future<bool> _connect() {
    if (_connected) return Future<bool>.value(true);
    return _connecting ??= _doConnect().whenComplete(() => _connecting = null);
  }

  Future<bool> _doConnect() async {
    if (kBazaarRsaKey.startsWith('REPLACE_')) return false;
    final completer = Completer<bool>();
    try {
      await FlutterPoolakey.connect(
        kBazaarRsaKey,
        onSucceed: () {
          _connected = true;
          if (!completer.isCompleted) completer.complete(true);
        },
        onFailed: () {
          _connected = false;
          if (!completer.isCompleted) completer.complete(false);
        },
        onDisconnected: () {
          _connected = false;
        },
      );
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () => false);
  }

  /// Starts the purchase flow. Returns true if the user owns Pro afterwards.
  Future<bool> purchasePro() async {
    lastPurchaseCancelled = false;
    if (!await _connect()) return false;
    try {
      // Already owned (e.g. reinstall)? Don't open the payment screen again.
      final owned = await FlutterPoolakey.getAllPurchasedProducts();
      if (owned.any((p) => p.productId == proSku)) {
        await _storePro(true);
        return true;
      }
      final info = await FlutterPoolakey.purchase(proSku, payload: 'solodesk_pro');
      if (info.productId == proSku) {
        // Not consumed on purpose: Pro is a permanent (non-consumable) unlock.
        await _storePro(true);
        return true;
      }
      return false;
    } catch (e) {
      lastPurchaseCancelled =
          e is PlatformException && e.toString().toLowerCase().contains('cancel');
      return false;
    }
  }

  /// Asks Cafe Bazaar whether the user owns Pro (also used for "Restore").
  /// If Bazaar can't be reached, falls back to the cached state.
  Future<bool> checkPurchased() async {
    if (!await _connect()) return readStoredPro();
    try {
      final owned = await FlutterPoolakey.getAllPurchasedProducts();
      final has = owned.any((p) => p.productId == proSku);
      await _storePro(has);
      return has;
    } catch (_) {
      return readStoredPro();
    }
  }

  /// Resets the connection state. Poolakey itself disconnects when the
  /// activity is destroyed, so no explicit native call is needed.
  Future<void> dispose() async {
    _connected = false;
    _connecting = null;
  }
}

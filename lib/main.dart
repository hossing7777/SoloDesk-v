import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solodesk/app.dart';
import 'package:solodesk/db/database.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/services/bazaar_iap_service.dart';
import 'package:solodesk/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = await AppDb.open();
  final storedPro = await BazaarIapService.instance.readStoredPro();
  await NotificationService.instance.init();

  final container = ProviderContainer(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
      isProProvider.overrideWith((ref) => storedPro),
    ],
  );
  runApp(UncontrolledProviderScope(container: container, child: const SoloDeskApp()));
  unawaited(_verifyPurchase(container));
}

/// Re-checks ownership with Cafe Bazaar in the background. Offline, the cached
/// state is kept; if Bazaar says the purchase is gone (refund), Pro is revoked.
Future<void> _verifyPurchase(ProviderContainer container) async {
  final iap = BazaarIapService.instance;
  await iap.init();
  container.read(isProProvider.notifier).state = await iap.checkPurchased();
}

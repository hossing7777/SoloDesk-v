import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solodesk/app.dart';
import 'package:solodesk/db/database.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/services/license_service.dart';
import 'package:solodesk/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = await AppDb.open();
  final isPro = await LicenseService().isActivated();
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
        isProProvider.overrideWith((ref) => isPro),
      ],
      child: const SoloDeskApp(),
    ),
  );
}

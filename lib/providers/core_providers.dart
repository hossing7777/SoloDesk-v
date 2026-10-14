import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solodesk/db/database.dart';
import 'package:solodesk/providers/settings_provider.dart';
import 'package:solodesk/services/auth_service.dart';

/// Overridden in main() (and in the demo container).
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

final dbProvider = Provider<AppDb>(
  (ref) => throw UnimplementedError('dbProvider must be overridden'),
);

/// True once a valid Pro license is activated (always true in the demo).
final isProProvider = StateProvider<bool>((ref) => false);

/// True inside the demo container (separate in-memory database).
final isDemoProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(ref.watch(prefsProvider)),
);

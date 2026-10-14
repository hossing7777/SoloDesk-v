import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences persisted in shared_preferences.
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.accent = 0,
    this.locale = '',
    this.currency = 'USD',
    this.lockEnabled = false,
    this.biometric = false,
    this.onboarded = false,
    this.businessName = '',
    this.businessEmail = '',
    this.logoPath = '',
  });

  final ThemeMode themeMode;
  final int accent;
  final String locale;
  final String currency;
  final bool lockEnabled;
  final bool biometric;
  final bool onboarded;
  final String businessName;
  final String businessEmail;
  final String logoPath;

  Settings copyWith({
    ThemeMode? themeMode,
    int? accent,
    String? locale,
    String? currency,
    bool? lockEnabled,
    bool? biometric,
    bool? onboarded,
    String? businessName,
    String? businessEmail,
    String? logoPath,
  }) =>
      Settings(
        themeMode: themeMode ?? this.themeMode,
        accent: accent ?? this.accent,
        locale: locale ?? this.locale,
        currency: currency ?? this.currency,
        lockEnabled: lockEnabled ?? this.lockEnabled,
        biometric: biometric ?? this.biometric,
        onboarded: onboarded ?? this.onboarded,
        businessName: businessName ?? this.businessName,
        businessEmail: businessEmail ?? this.businessEmail,
        logoPath: logoPath ?? this.logoPath,
      );
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier(SharedPreferences prefs)
      : _p = prefs,
        super(_load(prefs));

  final SharedPreferences _p;

  static Settings _load(SharedPreferences p) {
    final mode = p.getInt('themeMode') ?? 0;
    return Settings(
      themeMode: ThemeMode.values[mode < ThemeMode.values.length ? mode : 0],
      accent: p.getInt('accent') ?? 0,
      locale: p.getString('locale') ?? '',
      currency: p.getString('currency') ?? 'USD',
      lockEnabled: p.getBool('lockEnabled') ?? false,
      biometric: p.getBool('biometric') ?? false,
      onboarded: p.getBool('onboarded') ?? false,
      businessName: p.getString('businessName') ?? '',
      businessEmail: p.getString('businessEmail') ?? '',
      logoPath: p.getString('logoPath') ?? '',
    );
  }

  Future<void> setThemeMode(ThemeMode v) async {
    state = state.copyWith(themeMode: v);
    await _p.setInt('themeMode', v.index);
  }

  Future<void> setAccent(int v) async {
    state = state.copyWith(accent: v);
    await _p.setInt('accent', v);
  }

  Future<void> setLocale(String v) async {
    state = state.copyWith(locale: v);
    await _p.setString('locale', v);
  }

  Future<void> setCurrency(String v) async {
    state = state.copyWith(currency: v);
    await _p.setString('currency', v);
  }

  Future<void> setLockEnabled(bool v) async {
    state = state.copyWith(lockEnabled: v, biometric: v ? state.biometric : false);
    await _p.setBool('lockEnabled', v);
    if (!v) await _p.setBool('biometric', false);
  }

  Future<void> setBiometric(bool v) async {
    state = state.copyWith(biometric: v);
    await _p.setBool('biometric', v);
  }

  Future<void> setOnboarded(bool v) async {
    state = state.copyWith(onboarded: v);
    await _p.setBool('onboarded', v);
  }

  Future<void> setBusinessName(String v) async {
    state = state.copyWith(businessName: v);
    await _p.setString('businessName', v);
  }

  Future<void> setBusinessEmail(String v) async {
    state = state.copyWith(businessEmail: v);
    await _p.setString('businessEmail', v);
  }

  Future<void> setLogoPath(String v) async {
    state = state.copyWith(logoPath: v);
    await _p.setString('logoPath', v);
  }
}

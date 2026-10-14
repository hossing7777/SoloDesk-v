import 'package:flutter/widgets.dart';

/// Supported UI languages (must match the .arb files in lib/l10n).
class LocaleService {
  LocaleService._();

  static const List<String> codes = ['en', 'fa', 'ar', 'es', 'fr', 'de', 'pt', 'ru', 'hi', 'zh'];
  static const Set<String> rtl = {'fa', 'ar'};

  static const Map<String, String> _names = {
    'en': 'English',
    'fa': 'فارسی',
    'ar': 'العربية',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'ru': 'Русский',
    'hi': 'हिन्दी',
    'zh': '中文',
  };

  /// Empty code means "follow the system language".
  static Locale? toLocale(String code) => code.isEmpty ? null : Locale(code);

  static bool isRtl(String code) => rtl.contains(code);

  static String nativeName(String code) => _names[code] ?? code;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/l10n/gen/app_localizations.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/splash_screen.dart';
import 'package:solodesk/services/locale_service.dart';
import 'package:solodesk/theme/app_theme.dart';
import 'package:solodesk/theme/colors.dart';

/// MaterialApp wired to settings (theme, accent, language). Reused by the demo.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final accent = AppColors.accents[s.accent < AppColors.accents.length ? s.accent : 0];
    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(accent, Brightness.light),
      darkTheme: AppTheme.build(accent, Brightness.dark),
      themeMode: s.themeMode,
      locale: s.locale.isEmpty ? const Locale('fa') : LocaleService.toLocale(s.locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}

class SoloDeskApp extends StatelessWidget {
  const SoloDeskApp({super.key});

  @override
  Widget build(BuildContext context) => const AppRoot(home: SplashScreen());
}

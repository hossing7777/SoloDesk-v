import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/home_shell.dart';
import 'package:solodesk/screens/lock_screen.dart';
import 'package:solodesk/screens/onboarding_screen.dart';
import 'package:solodesk/utils/ext.dart';

/// Shows the logo briefly, then routes to onboarding / lock / home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), _go);
  }

  void _go() {
    if (!mounted) return;
    final s = ref.read(settingsProvider);
    final Widget next = !s.onboarded
        ? const OnboardingScreen()
        : (s.lockEnabled ? const LockScreen() : const HomeShell());
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 96, height: 96, excludeFromSemantics: true),
            const SizedBox(height: 16),
            Text(context.l10n.appName, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

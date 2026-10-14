import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solodesk/screens/demo_screen.dart';
import 'package:solodesk/screens/home_shell.dart';
import 'package:solodesk/screens/pricing_screen.dart';
import 'package:solodesk/services/notification_service.dart';
import 'package:solodesk/utils/constants.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/nav.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                SvgPicture.string(kHeroSvg, height: 140, semanticsLabel: l.appName),
                const SizedBox(height: 24),
                Text(l.appName, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(l.tagline, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await NotificationService.instance.requestPermission();
                      if (!context.mounted) return;
                      await Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(builder: (_) => const HomeShell()));
                    },
                    child: Text(l.getStarted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => pushPage<void>(context, const DemoScreen()),
                    child: Text(l.tryDemo),
                  ),
                ),
                TextButton(
                  onPressed: () => pushPage<void>(context, const PricingScreen()),
                  child: Text(l.pricing),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

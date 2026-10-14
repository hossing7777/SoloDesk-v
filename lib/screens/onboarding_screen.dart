import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/landing_screen.dart';
import 'package:solodesk/utils/ext.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).setOnboarded(true);
    if (!mounted) return;
    await Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => const LandingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pages = [
      (Icons.people_alt_outlined, l.onboarding1),
      (Icons.timer_outlined, l.onboarding2),
      (Icons.receipt_long_outlined, l.onboarding3),
    ];
    final last = _page == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(onPressed: _finish, child: Text(l.skip)),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final p in pages)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(p.$1, size: 96, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 32),
                          Text(p.$2,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                  child: Text(last ? l.getStarted : l.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

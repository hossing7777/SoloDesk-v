import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/paywall_screen.dart';
import 'package:solodesk/theme/colors.dart';
import 'package:solodesk/utils/ext.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _busy = false;

  Future<void> _run({required bool restore}) async {
    if (_busy) return;
    setState(() => _busy = true);
    await runPurchase(context, ref, restore: restore);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isPro = ref.watch(isProProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pricing)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l.freeFeatures),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(l.proFeatures),
            ),
          ),
          const SizedBox(height: 16),
          if (isPro)
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.success),
                title: Text(l.licensePro),
              ),
            )
          else ...[
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              onPressed: _busy ? null : () => _run(restore: false),
              child: _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.buyProButton, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : () => _run(restore: true),
              child: Text(l.restorePurchase),
            ),
          ],
        ],
      ),
    );
  }
}

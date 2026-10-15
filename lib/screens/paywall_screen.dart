import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/services/bazaar_iap_service.dart';
import 'package:solodesk/utils/ext.dart';

/// Runs purchase / restore, shows the result and updates the Pro state.
/// Shared by the paywall and the pricing screen.
Future<bool> runPurchase(
  BuildContext context,
  WidgetRef ref, {
  required bool restore,
}) async {
  final l = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final iap = BazaarIapService.instance;
  final ok = restore ? await iap.checkPurchased() : await iap.purchasePro();
  if (ok) {
    ref.read(isProProvider.notifier).state = true;
    messenger.showSnackBar(SnackBar(content: Text(l.purchaseSuccess)));
    return true;
  }
  final message = restore
      ? l.restoreNotFound
      : (iap.lastPurchaseCancelled ? l.purchaseCancelled : l.purchaseFailed);
  messenger.showSnackBar(SnackBar(content: Text(message)));
  return false;
}

/// Full-screen paywall. Pops `true` after a successful purchase/restore.
/// Always rendered in Persian + RTL (the Bazaar audience); delete the
/// Localizations.override wrapper to follow the app language instead.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key, this.limitReached = true});

  final bool limitReached;

  @override
  Widget build(BuildContext context) => Localizations.override(
        context: context,
        locale: const Locale('fa'),
        child: _PaywallBody(limitReached: limitReached),
      );
}

class _PaywallBody extends ConsumerStatefulWidget {
  const _PaywallBody({required this.limitReached});

  final bool limitReached;

  @override
  ConsumerState<_PaywallBody> createState() => _PaywallBodyState();
}

class _PaywallBodyState extends ConsumerState<_PaywallBody> {
  bool _busy = false;

  Future<void> _run({required bool restore}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await runPurchase(context, ref, restore: restore);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final features = [l.paywallFeature1, l.paywallFeature2, l.paywallFeature3];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.cancel,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.workspace_premium, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(l.paywallTitle,
                textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l.paywallSubtitle,
                textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            if (widget.limitReached) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l.trialLimitReached,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (final f in features)
              ListTile(
                leading: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                title: Text(f),
              ),
            const SizedBox(height: 24),
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
        ),
      ),
    );
  }
}

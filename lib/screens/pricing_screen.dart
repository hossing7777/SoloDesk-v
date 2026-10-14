import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/services/license_service.dart';
import 'package:solodesk/utils/constants.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:url_launcher/url_launcher.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  final TextEditingController _key = TextEditingController();

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await LicenseService().activate(_key.text);
    if (ok) ref.read(isProProvider.notifier).state = true;
    messenger.showSnackBar(SnackBar(content: Text(ok ? l.activated : l.invalidKey)));
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
              subtitle: isPro ? Text(l.licensePro) : null,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(l.buyNow),
            onPressed: () =>
                launchUrl(Uri.parse(kGumroadUrl), mode: LaunchMode.externalApplication),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _key,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l.licenseKey,
              hintText: 'SOLO-XXXXXXXX-XXXXXXXX',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _activate, child: Text(l.activate)),
        ],
      ),
    );
  }
}

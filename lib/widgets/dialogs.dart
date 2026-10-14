import 'package:flutter/material.dart';
import 'package:solodesk/screens/pricing_screen.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/nav.dart';

/// Generic confirmation dialog. Returns true when the user confirms.
Future<bool> confirmDialog(BuildContext context, String message, String confirmLabel) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(confirmLabel)),
      ],
    ),
  );
  return result ?? false;
}

/// Shown when a free-tier limit is reached.
Future<void> showUpgradeDialog(BuildContext context) async {
  final l = context.l10n;
  final go = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.upgradeTitle),
      content: Text(l.upgradeMessage),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.later)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.upgrade)),
      ],
    ),
  );
  if (go == true && context.mounted) {
    await pushPage<void>(context, const PricingScreen());
  }
}

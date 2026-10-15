import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/paywall_screen.dart';
import 'package:solodesk/utils/constants.dart';
import 'package:solodesk/utils/nav.dart';

/// Opens the full-screen paywall. Returns true if the user bought/restored Pro.
Future<bool> showPaywall(BuildContext context, {bool limitReached = true}) async {
  final bought =
      await pushPage<bool>(context, PaywallScreen(limitReached: limitReached));
  return bought == true;
}

/// Free-tier gate: call BEFORE inserting a client or an invoice.
/// Returns false (after showing the paywall) when the limit is hit and the
/// user does not buy Pro.
Future<bool> ensureWithinLimit(
  BuildContext context,
  WidgetRef ref, {
  required bool client,
}) async {
  if (ref.read(isProProvider)) return true;
  final db = ref.read(dbProvider);
  final count = client ? await db.clients.count() : await db.invoices.count();
  final max = client ? kFreeClients : kFreeInvoices;
  if (count < max) return true;
  if (!context.mounted) return false;
  return showPaywall(context);
}

/// Gate for Pro-only features (PDF export, backup, CSV).
Future<bool> ensurePro(BuildContext context, WidgetRef ref) async {
  if (ref.read(isProProvider)) return true;
  return showPaywall(context, limitReached: false);
}

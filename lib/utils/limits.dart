import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/utils/constants.dart';
import 'package:solodesk/widgets/dialogs.dart';

/// Free-tier gate: call BEFORE inserting a client or an invoice.
/// Returns false (after showing the upgrade dialog) when the limit is hit.
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
  if (context.mounted) await showUpgradeDialog(context);
  return false;
}

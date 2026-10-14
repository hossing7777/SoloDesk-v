import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/screens/invoices/invoice_detail_screen.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/nav.dart';
import 'package:solodesk/widgets/async_body.dart';
import 'package:solodesk/widgets/empty_state.dart';
import 'package:solodesk/widgets/invoice_tile.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cur = ref.watch(settingsProvider).currency;
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final names = {for (final c in clients) c.id: c.name};
    return AsyncBody<List<Invoice>>(
      value: ref.watch(invoicesProvider),
      builder: (list) {
        if (list.isEmpty) {
          return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l.noInvoices,
              message: l.noInvoicesHint);
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          itemBuilder: (context, i) => InvoiceTile(
            invoice: list[i],
            clientName: names[list[i].clientId] ?? '-',
            currency: cur,
            onTap: () => pushPage<void>(context, InvoiceDetailScreen(invoice: list[i])),
          ),
        );
      },
    );
  }
}

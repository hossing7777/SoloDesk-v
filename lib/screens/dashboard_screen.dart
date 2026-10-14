import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/screens/invoices/invoice_detail_screen.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/utils/nav.dart';
import 'package:solodesk/widgets/async_body.dart';
import 'package:solodesk/widgets/invoice_tile.dart';
import 'package:solodesk/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cur = ref.watch(settingsProvider).currency;
    final times = ref.watch(timeEntriesProvider).valueOrNull ?? const [];
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final names = {for (final c in clients) c.id: c.name};
    final w = (MediaQuery.sizeOf(context).width - 44) / 2;

    return AsyncBody<List<Invoice>>(
      value: ref.watch(invoicesProvider),
      builder: (list) {
        final now = DateTime.now();
        final outstanding =
            list.where((i) => i.status == Invoice.sent).fold<double>(0, (a, i) => a + i.total);
        final paidMonth = list.where((i) {
          final d = DateTime.fromMillisecondsSinceEpoch(i.issueDate);
          return i.status == Invoice.paid && d.year == now.year && d.month == now.month;
        }).fold<double>(0, (a, i) => a + i.total);
        final overdue = list.where((i) => i.isOverdue).length;
        final weekStart =
            DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final seconds = times
            .where((t) => t.startedAt >= weekStart.millisecondsSinceEpoch)
            .fold<int>(0, (a, t) => a + t.duration.inSeconds);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatCard(
                    width: w,
                    label: l.outstanding,
                    value: Fmt.money(outstanding, cur),
                    icon: Icons.hourglass_bottom),
                StatCard(
                    width: w,
                    label: l.paidThisMonth,
                    value: Fmt.money(paidMonth, cur),
                    icon: Icons.check_circle_outline),
                StatCard(
                    width: w,
                    label: l.overdueCount,
                    value: '$overdue',
                    icon: Icons.warning_amber_outlined),
                StatCard(
                    width: w,
                    label: l.hoursThisWeek,
                    value: (seconds / 3600).toStringAsFixed(1),
                    icon: Icons.timer_outlined),
              ],
            ),
            const SizedBox(height: 24),
            Text(l.recentInvoices, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final i in list.take(5))
              InvoiceTile(
                invoice: i,
                clientName: names[i.clientId] ?? '-',
                currency: cur,
                onTap: () => pushPage<void>(context, InvoiceDetailScreen(invoice: i)),
              ),
          ],
        );
      },
    );
  }
}

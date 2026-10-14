import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/services/backup_service.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cur = ref.watch(settingsProvider).currency;
    final invoices = ref.watch(invoicesProvider).valueOrNull ?? const <Invoice>[];
    final expenses = ref.watch(expensesProvider).valueOrNull ?? const [];
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];

    final now = DateTime.now();
    final months = [for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i)];
    bool inMonth(int ms, DateTime m) {
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      return d.year == m.year && d.month == m.month;
    }

    final revenue = [
      for (final m in months)
        invoices
            .where((i) => i.status == Invoice.paid && inMonth(i.issueDate, m))
            .fold<double>(0, (a, i) => a + i.total),
    ];
    final spent = [
      for (final m in months)
        expenses.where((e) => inMonth(e.date, m)).fold<double>(0, (a, e) => a + e.amount),
    ];
    final totalRevenue = revenue.fold<double>(0, (a, b) => a + b);
    final totalSpent = spent.fold<double>(0, (a, b) => a + b);

    Widget legend(Color c, String t) => Row(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(t),
        ]);

    return Scaffold(
      appBar: AppBar(title: Text(l.reports)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.last6Months, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(children: [
            legend(theme.colorScheme.primary, '${l.revenue}: ${Fmt.money(totalRevenue, cur)}'),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            legend(theme.colorScheme.error, '${l.expenses}: ${Fmt.money(totalSpent, cur)}'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final m = months[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${m.month}/${m.year % 100}',
                              style: theme.textTheme.bodySmall),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < months.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: revenue[i],
                        color: theme.colorScheme.primary,
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: spent[i],
                        color: theme.colorScheme.error,
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.table_chart_outlined),
            label: Text(l.exportCsv),
            onPressed: () => BackupService.shareInvoicesCsv(
              invoices,
              {for (final c in clients) c.id: c.name},
              cur,
            ),
          ),
        ],
      ),
    );
  }
}

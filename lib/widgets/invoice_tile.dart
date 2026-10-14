import 'package:flutter/material.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/utils/status.dart';

class InvoiceTile extends StatelessWidget {
  const InvoiceTile({
    super.key,
    required this.invoice,
    required this.clientName,
    required this.currency,
    required this.onTap,
  });

  final Invoice invoice;
  final String clientName;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(invoice.number),
        subtitle: Text('$clientName · ${Fmt.date(invoice.dueDate)}'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Fmt.money(invoice.total, currency),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              statusLabel(l, invoice),
              style: TextStyle(
                color: statusColor(invoice),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

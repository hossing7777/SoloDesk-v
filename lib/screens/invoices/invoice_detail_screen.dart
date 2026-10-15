import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/screens/invoices/invoice_form_screen.dart';
import 'package:solodesk/services/notification_service.dart';
import 'package:solodesk/services/pdf_service.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/utils/limits.dart';
import 'package:solodesk/utils/nav.dart';
import 'package:solodesk/utils/reminders.dart';
import 'package:solodesk/utils/status.dart';
import 'package:solodesk/utils/templates.dart';
import 'package:solodesk/widgets/dialogs.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  late Invoice _inv = widget.invoice;
  List<InvoiceItem> _items = const [];
  Client? _client;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(dbProvider);
    final fresh = await db.invoices.byId(widget.invoice.id!);
    if (fresh == null) return;
    final items = await db.invoices.items(fresh.id!);
    final client = fresh.clientId == null ? null : await db.clients.byId(fresh.clientId!);
    if (!mounted) return;
    setState(() {
      _inv = fresh;
      _items = items;
      _client = client;
    });
  }

  Future<void> _setStatus(int status) async {
    final db = ref.read(dbProvider);
    final l = context.l10n;
    final demo = ref.read(isDemoProvider);
    final cur = ref.read(settingsProvider).currency;
    final updated = _inv.copyWith(status: status);
    await db.invoices.update(updated);
    await syncReminder(demo: demo, invoice: updated, l: l, currency: cur);
    ref.invalidate(invoicesProvider);
    if (mounted) setState(() => _inv = updated);
  }

  Future<Uint8List> _pdf() async {
    final l = context.l10n;
    final settings = ref.read(settingsProvider);
    final lang = settings.locale.isEmpty
        ? Localizations.localeOf(context).languageCode
        : settings.locale;
    final template = await TemplateService.load(_inv.template);
    return PdfService.build(
      invoice: _inv,
      items: _items,
      client: _client,
      settings: settings,
      lang: lang,
      labels: PdfLabels.from(l),
      template: template,
    );
  }

  Future<void> _share() async {
    if (!await ensurePro(context, ref)) return;
    if (!mounted) return;
    final bytes = await _pdf();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_inv.number}.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: _inv.number);
  }

  Future<void> _print() async {
    if (!await ensurePro(context, ref)) return;
    if (!mounted) return;
    final bytes = await _pdf();
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: _inv.number);
  }

  /// Recurring invoices: clone with dates moved one month ahead (draft).
  Future<void> _duplicate() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!await ensureWithinLimit(context, ref, client: false)) return;
    final db = ref.read(dbProvider);
    int nextMonth(int ms) {
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateTime(d.year, d.month + 1, d.day).millisecondsSinceEpoch;
    }

    final copy = Invoice(
      number: await db.invoices.nextNumber(),
      clientId: _inv.clientId,
      issueDate: nextMonth(_inv.issueDate),
      dueDate: nextMonth(_inv.dueDate),
      tax: _inv.tax,
      notes: _inv.notes,
      recurring: true,
      template: _inv.template,
      total: _inv.total,
    );
    await db.invoices.saveWithItems(copy, _items);
    ref.invalidate(invoicesProvider);
    messenger.showSnackBar(SnackBar(content: Text(l.saved)));
  }

  Future<void> _delete() async {
    final l = context.l10n;
    if (!await confirmDialog(context, l.deleteConfirm, l.delete)) return;
    final demo = ref.read(isDemoProvider);
    await ref.read(dbProvider).invoices.delete(_inv.id!);
    if (!demo) await NotificationService.instance.cancel(_inv.id!);
    ref.invalidate(invoicesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cur = ref.watch(settingsProvider).currency;
    final subtotal = _items.fold<double>(0, (a, i) => a + i.amount);
    final taxAmount = subtotal * _inv.tax / 100;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_inv.number),
        actions: [
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(
                label: Text(statusLabel(l, _inv),
                    style: TextStyle(color: statusColor(_inv), fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Text(Fmt.money(_inv.total, cur), style: theme.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text('${l.billTo}: ${_client?.name ?? '-'}'),
          Text('${l.issueDate}: ${Fmt.date(_inv.issueDate)}'),
          Text('${l.dueDate}: ${Fmt.date(_inv.dueDate)}'),
          const Divider(height: 32),
          for (final i in _items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(i.description),
              subtitle: Text('${Fmt.number(i.qty)} × ${i.price.toStringAsFixed(2)}'),
              trailing: Text(i.amount.toStringAsFixed(2)),
            ),
          const Divider(height: 32),
          Text('${l.subtotal}: ${Fmt.money(subtotal, cur)}'),
          if (_inv.tax > 0) Text('${l.tax} ${Fmt.number(_inv.tax)}: ${Fmt.money(taxAmount, cur)}'),
          Text('${l.total}: ${Fmt.money(subtotal + taxAmount, cur)}',
              style: theme.textTheme.titleMedium),
          if (_inv.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('${l.notes}: ${_inv.notes}'),
          ],
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_inv.status == Invoice.draft)
                FilledButton.icon(
                  icon: const Icon(Icons.send_outlined),
                  label: Text(l.markSent),
                  onPressed: () => _setStatus(Invoice.sent),
                ),
              if (_inv.status != Invoice.paid)
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l.markPaid),
                  onPressed: () => _setStatus(Invoice.paid),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.share_outlined),
                label: Text(l.sharePdf),
                onPressed: _share,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.print_outlined),
                label: Text(l.printPdf),
                onPressed: _print,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: Text(l.edit),
                onPressed: () async {
                  await pushPage<void>(context, InvoiceFormScreen(invoice: _inv));
                  await _load();
                },
              ),
              if (_inv.recurring)
                OutlinedButton.icon(
                  icon: const Icon(Icons.repeat),
                  label: Text(l.duplicateNext),
                  onPressed: _duplicate,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

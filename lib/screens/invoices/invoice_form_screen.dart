import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/utils/limits.dart';
import 'package:solodesk/utils/reminders.dart';
import 'package:solodesk/utils/templates.dart';

class _ItemRow {
  _ItemRow({String desc = '', String qty = '1', String price = ''})
      : desc = TextEditingController(text: desc),
        qty = TextEditingController(text: qty),
        price = TextEditingController(text: price);

  final TextEditingController desc;
  final TextEditingController qty;
  final TextEditingController price;

  double get amount => Fmt.parse(qty.text) * Fmt.parse(price.text);

  void dispose() {
    desc.dispose();
    qty.dispose();
    price.dispose();
  }
}

class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key, this.invoice});

  final Invoice? invoice;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _tax = TextEditingController(text: '0');
  final TextEditingController _notes = TextEditingController();
  final List<_ItemRow> _rows = [];
  int? _clientId;
  int _issue = 0;
  int _due = 0;
  bool _recurring = false;
  String _template = 'classic';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _number.dispose();
    _tax.dispose();
    _notes.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    final db = ref.read(dbProvider);
    final inv = widget.invoice;
    final now = DateTime.now();
    if (inv == null) {
      _number.text = await db.invoices.nextNumber();
      _issue = now.millisecondsSinceEpoch;
      _due = now.add(const Duration(days: 14)).millisecondsSinceEpoch;
      _rows.add(_ItemRow());
    } else {
      _number.text = inv.number;
      _tax.text = Fmt.number(inv.tax);
      _notes.text = inv.notes;
      _clientId = inv.clientId;
      _issue = inv.issueDate;
      _due = inv.dueDate;
      _recurring = inv.recurring;
      _template = inv.template;
      final items = await db.invoices.items(inv.id!);
      for (final i in items) {
        _rows.add(_ItemRow(
            desc: i.description, qty: Fmt.number(i.qty), price: Fmt.number(i.price)));
      }
      if (_rows.isEmpty) _rows.add(_ItemRow());
    }
    if (mounted) setState(() => _loading = false);
  }

  double get _subtotal => _rows.fold<double>(0, (a, r) => a + r.amount);
  double get _total => _subtotal * (1 + Fmt.parse(_tax.text) / 100);

  Future<void> _pickDate({required bool due}) async {
    final current = DateTime.fromMillisecondsSinceEpoch(due ? _due : _issue);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (due) {
        _due = picked.millisecondsSinceEpoch;
      } else {
        _issue = picked.millisecondsSinceEpoch;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.invoice;
    if (existing == null && !await ensureWithinLimit(context, ref, client: false)) return;
    if (!mounted) return;
    final db = ref.read(dbProvider);
    final l = context.l10n;
    final demo = ref.read(isDemoProvider);
    final cur = ref.read(settingsProvider).currency;
    final invoice = Invoice(
      id: existing?.id,
      number: _number.text.trim(),
      clientId: _clientId,
      issueDate: _issue,
      dueDate: _due,
      status: existing?.status ?? Invoice.draft,
      tax: Fmt.parse(_tax.text),
      notes: _notes.text.trim(),
      recurring: _recurring,
      template: _template,
      total: _total,
    );
    final items = [
      for (final r in _rows)
        InvoiceItem(
          description: r.desc.text.trim(),
          qty: Fmt.parse(r.qty.text),
          price: Fmt.parse(r.price.text),
        ),
    ];
    final id = await db.invoices.saveWithItems(invoice, items);
    await syncReminder(demo: demo, invoice: invoice.copyWith(id: id), l: l, currency: cur);
    ref.invalidate(invoicesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.newInvoice)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final cur = ref.watch(settingsProvider).currency;
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final selected = clients.any((c) => c.id == _clientId) ? _clientId : null;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.invoice == null ? l.newInvoice : widget.invoice!.number)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _number,
              decoration: InputDecoration(labelText: l.invoiceNumber),
              validator: req,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selected,
              decoration: InputDecoration(labelText: l.client),
              validator: (v) => v == null ? l.fieldRequired : null,
              items: [
                for (final c in clients) DropdownMenuItem<int>(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _clientId = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.issueDate),
              subtitle: Text(Fmt.date(_issue)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(due: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.dueDate),
              subtitle: Text(Fmt.date(_due)),
              trailing: const Icon(Icons.event_outlined),
              onTap: () => _pickDate(due: true),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _rows.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _rows[i].desc,
                        decoration: InputDecoration(labelText: l.description),
                        validator: req,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rows[i].qty,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: l.quantity),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _rows[i].price,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: l.price),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (_rows.length > 1)
                            IconButton(
                              tooltip: l.delete,
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => setState(() => _rows.removeAt(i).dispose()),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l.addItem),
              onPressed: () => setState(() => _rows.add(_ItemRow())),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tax,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l.tax),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _template,
              decoration: InputDecoration(labelText: l.template),
              items: [
                for (final id in TemplateService.ids)
                  DropdownMenuItem<String>(value: id, child: Text(templateLabel(l, id))),
              ],
              onChanged: (v) => setState(() => _template = v ?? _template),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.recurring),
              value: _recurring,
              onChanged: (v) => setState(() => _recurring = v),
            ),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.notes),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text('${l.total}: ${Fmt.money(_total, cur)}',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

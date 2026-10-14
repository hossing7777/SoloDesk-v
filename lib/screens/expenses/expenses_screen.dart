import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/expense.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/widgets/async_body.dart';
import 'package:solodesk/widgets/dialogs.dart';
import 'package:solodesk/widgets/empty_state.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, Expense? existing) async {
    final saved = await showDialog<Expense>(
      context: context,
      builder: (_) => _ExpenseDialog(existing: existing),
    );
    if (saved == null) return;
    final dao = ref.read(dbProvider).expenses;
    if (existing == null) {
      await dao.insert(saved);
    } else {
      await dao.update(saved);
    }
    ref.invalidate(expensesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cur = ref.watch(settingsProvider).currency;
    return Scaffold(
      appBar: AppBar(title: Text(l.expenses)),
      floatingActionButton: FloatingActionButton(
        tooltip: l.newExpense,
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: AsyncBody<List<Expense>>(
        value: ref.watch(expensesProvider),
        builder: (list) {
          if (list.isEmpty) {
            return EmptyState(
                icon: Icons.payments_outlined, title: l.noExpenses, message: l.noExpensesHint);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];
              return Card(
                child: ListTile(
                  title: Text(e.title),
                  subtitle: Text([Fmt.date(e.date), e.category].where((s) => s.isNotEmpty).join(' · ')),
                  onTap: () => _edit(context, ref, e),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Fmt.money(e.amount, cur),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (!await confirmDialog(context, l.deleteConfirm, l.delete)) return;
                          await ref.read(dbProvider).expenses.delete(e.id!);
                          ref.invalidate(expensesProvider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog({this.existing});

  final Expense? existing;

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(text: widget.existing?.title);
  late final TextEditingController _amount = TextEditingController(
      text: widget.existing == null ? '' : Fmt.number(widget.existing!.amount));
  late final TextEditingController _category =
      TextEditingController(text: widget.existing?.category);
  late int _date = widget.existing?.date ?? DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked.millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l.newExpense : l.expenses),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: l.title),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.amount),
                validator: (v) => Fmt.parse(v ?? '') <= 0 ? l.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _category,
                decoration: InputDecoration(labelText: l.category),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.date),
                subtitle: Text(Fmt.date(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              Expense(
                id: widget.existing?.id,
                title: _title.text.trim(),
                amount: Fmt.parse(_amount.text),
                date: _date,
                category: _category.text.trim(),
              ),
            );
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/limits.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.client});

  final Client? client;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.client?.name);
  late final TextEditingController _email = TextEditingController(text: widget.client?.email);
  late final TextEditingController _phone = TextEditingController(text: widget.client?.phone);
  late final TextEditingController _address = TextEditingController(text: widget.client?.address);
  late final TextEditingController _notes = TextEditingController(text: widget.client?.notes);

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.client;
    if (existing == null && !await ensureWithinLimit(context, ref, client: true)) return;
    final client = Client(
      id: existing?.id,
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      notes: _notes.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    final dao = ref.read(dbProvider).clients;
    if (existing == null) {
      await dao.insert(client);
    } else {
      await dao.update(client);
    }
    ref.invalidate(clientsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? l.newClient : widget.client!.name)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l.name),
                validator: req),
            const SizedBox(height: 12),
            TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l.email)),
            const SizedBox(height: 12),
            TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l.phone)),
            const SizedBox(height: 12),
            TextFormField(
                controller: _address,
                maxLines: 2,
                decoration: InputDecoration(labelText: l.address)),
            const SizedBox(height: 12),
            TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(labelText: l.notes)),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

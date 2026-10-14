import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/project.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.project});

  final Project? project;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.project?.name);
  late final TextEditingController _rate =
      TextEditingController(text: widget.project == null ? '' : Fmt.number(widget.project!.rate));
  late int? _clientId = widget.project?.clientId;

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.project;
    final project = Project(
      id: existing?.id,
      clientId: _clientId,
      name: _name.text.trim(),
      rate: Fmt.parse(_rate.text),
      done: existing?.done ?? false,
      createdAt: existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    final dao = ref.read(dbProvider).projects;
    if (existing == null) {
      await dao.insert(project);
    } else {
      await dao.update(project);
    }
    ref.invalidate(projectsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final selected = clients.any((c) => c.id == _clientId) ? _clientId : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.project == null ? l.newProject : widget.project!.name)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l.name),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selected,
              decoration: InputDecoration(labelText: l.client),
              items: [
                for (final c in clients) DropdownMenuItem<int>(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _clientId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l.hourlyRate),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/screens/clients/client_form_screen.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/nav.dart';
import 'package:solodesk/widgets/async_body.dart';
import 'package:solodesk/widgets/dialogs.dart';
import 'package:solodesk/widgets/empty_state.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncBody<List<Client>>(
      value: ref.watch(clientsProvider),
      builder: (list) {
        if (list.isEmpty) {
          return EmptyState(
              icon: Icons.people_outline, title: l.noClients, message: l.noClientsHint);
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final c = list[i];
            final sub = [c.email, c.phone].where((s) => s.isNotEmpty).join(' · ');
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(c.name.characters.first.toUpperCase())),
                title: Text(c.name),
                subtitle: sub.isEmpty ? null : Text(sub),
                onTap: () => pushPage<void>(context, ClientFormScreen(client: c)),
                trailing: IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (!await confirmDialog(context, l.deleteConfirm, l.delete)) return;
                    await ref.read(dbProvider).clients.delete(c.id!);
                    ref.invalidate(clientsProvider);
                    ref.invalidate(projectsProvider);
                    ref.invalidate(invoicesProvider);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

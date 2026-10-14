import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/project.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/screens/projects/project_form_screen.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/utils/nav.dart';
import 'package:solodesk/widgets/async_body.dart';
import 'package:solodesk/widgets/dialogs.dart';
import 'package:solodesk/widgets/empty_state.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cur = ref.watch(settingsProvider).currency;
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final names = {for (final c in clients) c.id: c.name};
    return AsyncBody<List<Project>>(
      value: ref.watch(projectsProvider),
      builder: (list) {
        if (list.isEmpty) {
          return EmptyState(
              icon: Icons.folder_open, title: l.noProjects, message: l.noProjectsHint);
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final p = list[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(p.name),
                subtitle: Text('${names[p.clientId] ?? '-'} · ${Fmt.money(p.rate, cur)}/h'),
                onTap: () => pushPage<void>(context, ProjectFormScreen(project: p)),
                trailing: IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (!await confirmDialog(context, l.deleteConfirm, l.delete)) return;
                    await ref.read(dbProvider).projects.delete(p.id!);
                    ref.invalidate(projectsProvider);
                    ref.invalidate(timeEntriesProvider);
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/project.dart';
import 'package:solodesk/models/time_entry.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/providers/data_providers.dart';
import 'package:solodesk/services/foreground_timer_service.dart';
import 'package:solodesk/services/notification_service.dart';
import 'package:solodesk/utils/ext.dart';
import 'package:solodesk/utils/format.dart';
import 'package:solodesk/widgets/async_body.dart';
import 'package:solodesk/widgets/empty_state.dart';

/// Time tracker. A running timer survives app restarts (shared_preferences)
/// and, outside the demo, is backed by the native foreground service.
class TimeScreen extends ConsumerStatefulWidget {
  const TimeScreen({super.key});

  @override
  ConsumerState<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends ConsumerState<TimeScreen> {
  Timer? _ticker;
  int? _projectId;
  int? _startMs;
  Duration _elapsed = Duration.zero;

  String get _kProject => ref.read(isDemoProvider) ? 'demo_timer_project' : 'timer_project';
  String get _kStart => ref.read(isDemoProvider) ? 'demo_timer_start' : 'timer_start';

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsProvider);
    _projectId = prefs.getInt(_kProject);
    _startMs = prefs.getInt(_kStart);
    if (_startMs != null) _run();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _run() {
    void tick() {
      final start = _startMs;
      if (start == null) return;
      setState(() => _elapsed =
          Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - start));
    }

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    _elapsed = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _startMs!);
  }

  Future<void> _start(List<Project> projects) async {
    final id = _projectId;
    if (id == null || projects.isEmpty) return;
    final prefs = ref.read(prefsProvider);
    final demo = ref.read(isDemoProvider);
    final title = context.l10n.timerNotifTitle;
    final name = projects.firstWhere((p) => p.id == id, orElse: () => projects.first).name;
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_kProject, id);
    await prefs.setInt(_kStart, now);
    setState(() => _startMs = now);
    _run();
    if (!demo) {
      await NotificationService.instance.requestPermission();
      await ForegroundTimerService.start(title: title, text: name, startMillis: now);
    }
  }

  Future<void> _stop() async {
    final id = _projectId;
    final start = _startMs;
    if (id == null || start == null) return;
    _ticker?.cancel();
    final prefs = ref.read(prefsProvider);
    final demo = ref.read(isDemoProvider);
    await ref.read(dbProvider).timeEntries.insert(TimeEntry(
        projectId: id, startedAt: start, endedAt: DateTime.now().millisecondsSinceEpoch));
    await prefs.remove(_kProject);
    await prefs.remove(_kStart);
    if (!demo) await ForegroundTimerService.stop();
    ref.invalidate(timeEntriesProvider);
    if (mounted) {
      setState(() {
        _startMs = null;
        _elapsed = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final projects = ref.watch(projectsProvider).valueOrNull ?? const <Project>[];
    final names = {for (final p in projects) p.id: p.name};
    final running = _startMs != null;
    final selected = projects.any((p) => p.id == _projectId) ? _projectId : null;
    return Scaffold(
      appBar: AppBar(title: Text(l.timeTracker)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: selected,
                    decoration: InputDecoration(labelText: l.selectProject),
                    items: [
                      for (final p in projects)
                        DropdownMenuItem<int>(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: running ? null : (v) => setState(() => _projectId = v),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: false,
                    child: Text(Fmt.duration(_elapsed),
                        style: Theme.of(context).textTheme.displayMedium),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: running
                        ? FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error),
                            icon: const Icon(Icons.stop),
                            label: Text(l.stop),
                            onPressed: _stop,
                          )
                        : FilledButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l.start),
                            onPressed: selected == null ? null : () => _start(projects),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AsyncBody<List<TimeEntry>>(
            value: ref.watch(timeEntriesProvider),
            builder: (list) {
              if (list.isEmpty) {
                return SizedBox(
                    height: 240,
                    child: EmptyState(icon: Icons.timer_off_outlined, title: l.noEntries));
              }
              return Column(
                children: [
                  for (final e in list)
                    Card(
                      child: ListTile(
                        title: Text(names[e.projectId] ?? '-'),
                        subtitle: Text(Fmt.date(e.startedAt)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Fmt.duration(e.duration)),
                            IconButton(
                              tooltip: l.delete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await ref.read(dbProvider).timeEntries.delete(e.id!);
                                ref.invalidate(timeEntriesProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

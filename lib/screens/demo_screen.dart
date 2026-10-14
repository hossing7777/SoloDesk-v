import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/app.dart';
import 'package:solodesk/db/database.dart';
import 'package:solodesk/db/seed.dart';
import 'package:solodesk/providers/core_providers.dart';
import 'package:solodesk/screens/home_shell.dart';
import 'package:sqflite/sqflite.dart';

/// Runs the whole app against a SEPARATE in-memory database inside its own
/// ProviderContainer + Navigator, so real data is never touched. Everything is
/// discarded when the demo closes.
class DemoScreen extends ConsumerStatefulWidget {
  const DemoScreen({super.key});

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  ProviderContainer? _container;
  AppDb? _db;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final db = await AppDb.open(path: inMemoryDatabasePath);
    await seedDemo(db);
    if (!mounted) {
      await db.close();
      return;
    }
    final container = ProviderContainer(overrides: [
      prefsProvider.overrideWithValue(ref.read(prefsProvider)),
      dbProvider.overrideWithValue(db),
      isProProvider.overrideWith((ref) => true),
      isDemoProvider.overrideWithValue(true),
    ]);
    setState(() {
      _db = db;
      _container = container;
    });
  }

  @override
  void dispose() {
    _container?.dispose();
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = _container;
    if (container == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final outer = context;
    return UncontrolledProviderScope(
      container: container,
      child: AppRoot(home: HomeShell(onExitDemo: () => Navigator.of(outer).pop())),
    );
  }
}

import 'package:path/path.dart' as p;
import 'package:solodesk/db/daos/dao.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/models/expense.dart';
import 'package:solodesk/models/project.dart';
import 'package:solodesk/models/time_entry.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite wrapper. Use [AppDb.open] for the real database and
/// `AppDb.open(path: inMemoryDatabasePath)` for the throw-away demo database.
class AppDb {
  AppDb._(this.db);

  /// Bump when the schema changes and add a step to [_migrate].
  static const int schemaVersion = 1;

  /// Tables in dependency order (children last).
  static const List<String> tables = [
    'clients',
    'projects',
    'time_entries',
    'invoices',
    'invoice_items',
    'expenses',
  ];

  final Database db;

  late final Dao<Client> clients = Dao<Client>(
      db, 'clients', Client.fromJson, (c) => c.toJson(), (c) => c.id);
  late final Dao<Project> projects = Dao<Project>(
      db, 'projects', Project.fromJson, (c) => c.toJson(), (c) => c.id);
  late final Dao<TimeEntry> timeEntries = Dao<TimeEntry>(
      db, 'time_entries', TimeEntry.fromJson, (c) => c.toJson(), (c) => c.id);
  late final Dao<Expense> expenses = Dao<Expense>(
      db, 'expenses', Expense.fromJson, (c) => c.toJson(), (c) => c.id);
  late final InvoiceDao invoices = InvoiceDao(db);

  static Future<AppDb> open({String? path}) async {
    final target = path ?? p.join(await getDatabasesPath(), 'solodesk.db');
    final database = await openDatabase(
      target,
      version: schemaVersion,
      // In-memory databases must not be shared between opens.
      singleInstance: target != inMemoryDatabasePath,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, v) async {
        await _create(d);
        await d.insert('schema_version', {'version': v});
      },
      onUpgrade: _migrate,
    );
    return AppDb._(database);
  }

  static Future<void> _create(Database d) async {
    await d.execute('CREATE TABLE schema_version(version INTEGER NOT NULL)');
    await d.execute('''CREATE TABLE clients(
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT,
      phone TEXT, address TEXT, notes TEXT, created_at INTEGER NOT NULL)''');
    await d.execute('''CREATE TABLE projects(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      client_id INTEGER REFERENCES clients(id) ON DELETE SET NULL,
      name TEXT NOT NULL, rate REAL NOT NULL DEFAULT 0,
      done INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL)''');
    await d.execute('''CREATE TABLE time_entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
      started_at INTEGER NOT NULL, ended_at INTEGER NOT NULL, note TEXT)''');
    await d.execute('''CREATE TABLE invoices(
      id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT NOT NULL,
      client_id INTEGER REFERENCES clients(id) ON DELETE SET NULL,
      issue_date INTEGER NOT NULL, due_date INTEGER NOT NULL,
      status INTEGER NOT NULL DEFAULT 0, tax REAL NOT NULL DEFAULT 0,
      notes TEXT, recurring INTEGER NOT NULL DEFAULT 0,
      template TEXT NOT NULL DEFAULT 'classic', total REAL NOT NULL DEFAULT 0)''');
    await d.execute('''CREATE TABLE invoice_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
      description TEXT, qty REAL NOT NULL, price REAL NOT NULL)''');
    await d.execute('''CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,
      amount REAL NOT NULL, date INTEGER NOT NULL, category TEXT)''');
  }

  /// Future migrations: add `if (oldV < 2) { ... }` blocks here.
  static Future<void> _migrate(Database d, int oldV, int newV) async {
    await d.update('schema_version', {'version': newV});
  }

  /// Deletes every row (children first). Used by "Reset all data".
  Future<void> resetAll() => db.transaction((txn) async {
        for (final t in tables.reversed) {
          await txn.delete(t);
        }
      });

  Future<void> close() => db.close();
}

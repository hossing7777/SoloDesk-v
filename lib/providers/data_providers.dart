import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/models/expense.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/models/project.dart';
import 'package:solodesk/models/time_entry.dart';
import 'package:solodesk/providers/core_providers.dart';

final clientsProvider = FutureProvider<List<Client>>(
  (ref) => ref.watch(dbProvider).clients.all(orderBy: 'name COLLATE NOCASE'),
);

final projectsProvider = FutureProvider<List<Project>>(
  (ref) => ref.watch(dbProvider).projects.all(orderBy: 'created_at DESC'),
);

final invoicesProvider = FutureProvider<List<Invoice>>(
  (ref) => ref.watch(dbProvider).invoices.all(orderBy: 'issue_date DESC, id DESC'),
);

final expensesProvider = FutureProvider<List<Expense>>(
  (ref) => ref.watch(dbProvider).expenses.all(orderBy: 'date DESC'),
);

final timeEntriesProvider = FutureProvider<List<TimeEntry>>(
  (ref) => ref.watch(dbProvider).timeEntries.all(orderBy: 'started_at DESC'),
);

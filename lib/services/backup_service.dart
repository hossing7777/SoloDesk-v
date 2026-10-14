import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solodesk/db/database.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/utils/format.dart';

/// Exports data through the system share sheet (JSON backup, CSV report).
class BackupService {
  BackupService._();

  static Future<File> _write(String name, String content) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$name').writeAsString(content);
  }

  static Future<void> shareBackup(AppDb db) async {
    final data = <String, Object?>{
      'app': 'SoloDesk',
      'schema_version': AppDb.schemaVersion,
      'exported_at': DateTime.now().toIso8601String(),
    };
    for (final table in AppDb.tables) {
      data[table] = await db.db.query(table);
    }
    final file = await _write(
      'solodesk-backup.json',
      const JsonEncoder.withIndent('  ').convert(data),
    );
    await Share.shareXFiles([XFile(file.path)]);
  }

  static Future<void> shareInvoicesCsv(
    List<Invoice> invoices,
    Map<int?, String> clientNames,
    String currency,
  ) async {
    final rows = <List<Object?>>[
      ['number', 'client', 'issue_date', 'due_date', 'status', 'total', 'currency'],
      for (final i in invoices)
        [
          i.number,
          clientNames[i.clientId] ?? '',
          Fmt.date(i.issueDate),
          Fmt.date(i.dueDate),
          i.status == Invoice.paid ? 'paid' : (i.status == Invoice.sent ? 'sent' : 'draft'),
          i.total.toStringAsFixed(2),
          currency,
        ],
    ];
    final file = await _write('solodesk-invoices.csv', const ListToCsvConverter().convert(rows));
    await Share.shareXFiles([XFile(file.path)]);
  }
}

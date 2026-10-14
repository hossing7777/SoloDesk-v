import 'package:solodesk/models/invoice.dart';
import 'package:sqflite/sqflite.dart';

/// Minimal generic DAO: one instance per table.
class Dao<T> {
  Dao(this.db, this.table, this.fromJson, this.toJson, this.idOf);

  final Database db;
  final String table;
  final T Function(Map<String, Object?>) fromJson;
  final Map<String, Object?> Function(T) toJson;
  final int? Function(T) idOf;

  Future<List<T>> all({String? orderBy}) async {
    final rows = await db.query(table, orderBy: orderBy);
    return rows.map(fromJson).toList();
  }

  Future<T?> byId(int id) async {
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : fromJson(rows.first);
  }

  Future<int> count() async =>
      Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table')) ?? 0;

  Future<int> insert(T value) => db.insert(table, toJson(value));

  Future<void> update(T value) =>
      db.update(table, toJson(value), where: 'id = ?', whereArgs: [idOf(value)]);

  Future<void> delete(int id) => db.delete(table, where: 'id = ?', whereArgs: [id]);
}

/// Invoices own line items, so saving happens in one transaction.
class InvoiceDao extends Dao<Invoice> {
  InvoiceDao(Database db)
      : super(db, 'invoices', Invoice.fromJson, (i) => i.toJson(), (i) => i.id);

  Future<List<InvoiceItem>> items(int invoiceId) async {
    final rows = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      orderBy: 'id',
    );
    return rows.map(InvoiceItem.fromJson).toList();
  }

  Future<int> saveWithItems(Invoice invoice, List<InvoiceItem> items) {
    return db.transaction((txn) async {
      final int id;
      if (invoice.id == null) {
        id = await txn.insert('invoices', invoice.toJson());
      } else {
        id = invoice.id!;
        await txn.update('invoices', invoice.toJson(), where: 'id = ?', whereArgs: [id]);
        await txn.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [id]);
      }
      for (final item in items) {
        await txn.insert('invoice_items', item.toJson(forInvoice: id));
      }
      return id;
    });
  }

  Future<String> nextNumber() async {
    final maxId = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COALESCE(MAX(id), 0) FROM invoices'),
        ) ??
        0;
    return 'INV-${(maxId + 1).toString().padLeft(4, '0')}';
  }
}

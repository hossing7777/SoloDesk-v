import 'package:solodesk/db/database.dart';
import 'package:solodesk/models/client.dart';
import 'package:solodesk/models/expense.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/models/project.dart';
import 'package:solodesk/models/time_entry.dart';

/// Fills the in-memory demo database with sample data.
Future<void> seedDemo(AppDb db) async {
  final now = DateTime.now();
  int day(int offset) => now.add(Duration(days: offset)).millisecondsSinceEpoch;

  final acme = await db.clients.insert(Client(
      name: 'Acme Studio', email: 'hello@acme.example', phone: '+1 555 0100', createdAt: day(-60)));
  final nova = await db.clients.insert(Client(
      name: 'Nova Labs', email: 'team@nova.example', phone: '+44 20 7946 0000', createdAt: day(-40)));
  await db.clients.insert(Client(name: 'Kiwi Café', email: 'kiwi@cafe.example', createdAt: day(-10)));

  final web = await db.projects
      .insert(Project(clientId: acme, name: 'Website redesign', rate: 60, createdAt: day(-50)));
  final app = await db.projects
      .insert(Project(clientId: nova, name: 'Mobile app MVP', rate: 80, createdAt: day(-30)));

  for (var i = 0; i < 6; i++) {
    await db.timeEntries.insert(TimeEntry(
        projectId: i.isEven ? web : app,
        startedAt: day(-i) - 3 * 3600 * 1000,
        endedAt: day(-i)));
  }

  // Paid invoices over the last 6 months (feeds the reports chart).
  for (var m = 1; m <= 5; m++) {
    final issued = DateTime(now.year, now.month - m, 10).millisecondsSinceEpoch;
    final amount = 400.0 + m * 150;
    await db.invoices.saveWithItems(
      Invoice(
        number: 'INV-H$m',
        clientId: m.isEven ? acme : nova,
        issueDate: issued,
        dueDate: issued + 14 * 86400000,
        status: Invoice.paid,
        total: amount,
      ),
      [InvoiceItem(description: 'Consulting', qty: 1, price: amount)],
    );
    await db.expenses.insert(Expense(
        title: 'Software', amount: 40.0 + m * 10, date: issued, category: 'Tools'));
  }
  await db.invoices.saveWithItems(
    Invoice(
      number: 'INV-D1',
      clientId: acme,
      issueDate: day(-30),
      dueDate: day(-10),
      status: Invoice.sent,
      total: 1200,
      recurring: true,
    ),
    const [InvoiceItem(description: 'Design sprint', qty: 20, price: 60)],
  );
  await db.invoices.saveWithItems(
    Invoice(
      number: 'INV-D2',
      clientId: nova,
      issueDate: day(-2),
      dueDate: day(12),
      total: 960,
      template: 'modern',
    ),
    const [InvoiceItem(description: 'App development', qty: 12, price: 80)],
  );
}

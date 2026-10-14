import 'package:solodesk/l10n/gen/app_localizations.dart';
import 'package:solodesk/models/invoice.dart';
import 'package:solodesk/services/notification_service.dart';
import 'package:solodesk/utils/format.dart';

/// Schedules the overdue reminder for sent invoices and cancels it otherwise.
Future<void> syncReminder({
  required bool demo,
  required Invoice invoice,
  required AppLocalizations l,
  required String currency,
}) async {
  final id = invoice.id;
  if (id == null || demo) return;
  final service = NotificationService.instance;
  if (invoice.status == Invoice.sent) {
    await service.scheduleOverdue(
      id: id,
      title: l.overdueNotifTitle,
      body: '${invoice.number} · ${Fmt.money(invoice.total, currency)} · ${l.overdueNotifBody}',
      channelName: l.notifChannel,
      due: DateTime.fromMillisecondsSinceEpoch(invoice.dueDate),
    );
  } else {
    await service.cancel(id);
  }
}

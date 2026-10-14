import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the "invoice overdue" reminder (morning after the due date).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> requestPermission() async {
    if (!_ready) return;
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleOverdue({
    required int id,
    required String title,
    required String body,
    required String channelName,
    required DateTime due,
  }) async {
    if (!_ready) return;
    final when = DateTime(due.year, due.month, due.day, 9).add(const Duration(days: 1));
    if (when.isBefore(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        // Converting an absolute instant, so the UTC location is correct.
        tz.TZDateTime.from(when, tz.UTC),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'overdue_invoices',
            channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        // Inexact scheduling works without the exact-alarm permission prompt.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Scheduling is best-effort; never block saving an invoice.
    }
  }

  Future<void> cancel(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id);
  }
}

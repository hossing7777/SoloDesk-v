import 'package:flutter/services.dart';

/// Dart side of the native Kotlin TimerService (foreground service with a
/// persistent chronometer notification). Channel is handled in MainActivity.kt.
class ForegroundTimerService {
  ForegroundTimerService._();

  static const MethodChannel _channel = MethodChannel('com.solodesk.freelance/timer');

  static Future<void> start({
    required String title,
    required String text,
    required int startMillis,
  }) async {
    try {
      await _channel.invokeMethod<void>('start', {
        'title': title,
        'text': text,
        'start': startMillis,
      });
    } catch (_) {
      // The tracker still works in-app if the service cannot start.
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {
      // Nothing to stop.
    }
  }
}

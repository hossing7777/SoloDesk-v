package com.solodesk.freelance

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth (biometric prompt).
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.solodesk.freelance/timer")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val intent = Intent(this, TimerService::class.java).apply {
                            putExtra("title", call.argument<String>("title"))
                            putExtra("text", call.argument<String>("text"))
                            putExtra(
                                "start",
                                call.argument<Number>("start")?.toLong() ?: System.currentTimeMillis()
                            )
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }
                    "stop" -> {
                        stopService(Intent(this, TimerService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

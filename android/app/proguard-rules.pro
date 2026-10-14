# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.**
# App (MainActivity + foreground TimerService)
-keep class com.solodesk.freelance.** { *; }
# flutter_local_notifications (Gson)
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.reflect.TypeToken

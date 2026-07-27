# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Drift / sqlite3
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep model classes used for JSON parsing (lesson/quiz content)
-keep class com.pythonchi.app.** { *; }

# Flutter references Google Play Core's "deferred components" (dynamic
# feature delivery) API even though this app doesn't use that feature.
# Without the play-core library on the classpath, R8 fails with "Missing
# class" errors for these referenced-but-unused classes. Since we never
# call into deferred components, it's safe to tell R8 not to warn about
# them instead of pulling in the whole play-core dependency.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**


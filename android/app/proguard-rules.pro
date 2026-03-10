# Flutter-specific ProGuard rules
# These rules tell ProGuard to keep Flutter-specific code safe from minification

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Dart VM classes
-keep class com.dart.** { *; }

# Keep Riverpod-related code
-keep class riverpod.** { *; }
-keep class flutter_riverpod.** { *; }

# Keep generated code
-keep class **.g.dart { *; }

# Keep SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep View constructors (required for reflection)
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep the R class
-keep class **.R$* {
    public static <fields>;
}

# Keep BuildConfig
-keep class **.BuildConfig {
    public static final *** *;
}

# Google Play Core - Required for Play Store features
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.tasks.Task { *; }

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep custom application classes
-keepclasseswithmembernames class * extends android.app.Activity {
    public void onCreate(android.os.Bundle);
}

-keepclasseswithmembernames class * extends android.content.BroadcastReceiver {
    public void onReceive(android.content.Context, android.content.Intent);
}

-keepclasseswithmembernames class * extends android.content.ContentProvider {
    public void onCreate();
}

-keepclasseswithmembernames class * extends android.app.Service {
    public void onCreate();
    public int onStartCommand(android.content.Intent, int, int);
    public android.os.IBinder onBind(android.content.Intent);
}

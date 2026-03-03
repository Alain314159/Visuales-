# Flutter specific rules
-keep class io.flutter.** { *; }
-keep class com.google.android.material.** { *; }
-keep class androidx.** { *; }

# Provider
-keep class provider.** { *; }
-keep interface provider.** { *; }

# Dio
-keep class io.dio.** { *; }
-keep interface io.dio.** { *; }
-dontwarn io.dio.**

# Shared Preferences
-keep class android.content.SharedPreferences { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimization flags
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Keep app entry point and main components
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove unused resources during shrinking
-dontshrink

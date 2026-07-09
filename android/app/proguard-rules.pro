## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Flutter Play Store Split - Ignore missing classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasksupport.**
-dontwarn com.google.android.play.core.tasks.**

## Google Fonts
-keep class com.google.android.gms.** { *; }

## Dio
-keep class retrofit.** { *; }
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

## Hive
-keep class com.hivemq.** { *; }
-dontwarn com.hivemq.**

## Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

## With R8 full mode generic signatures are stripped for classes that are not kept.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

## Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Video Player
-keep class io.flutter.plugins.videoplayer.VideoPlayerPlugin { *; }

## Wavemart App - Keep models and core classes
-keep class et.wavemart.app.** { *; }
-keep class **.*_** { *; }

## Keep JSON serialization classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

## Keep Hive TypeId classes
-keep @com.hivemq.hive.annotations.HiveType class * { *; }

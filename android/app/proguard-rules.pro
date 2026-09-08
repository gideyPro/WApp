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

## AndroidX Credentials (Restore Credentials API)
-keep class androidx.credentials.** { *; }
-dontwarn androidx.credentials.**

## Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Video Player
-keep class io.flutter.plugins.videoplayer.VideoPlayerPlugin { *; }

## Wavemart App Entrypoint
-keep class et.wavemart.app.MainActivity { *; }

## Keep generic signatures and annotations
-keepattributes *Annotation*,Signature,Exceptions,InnerClasses,EnclosingMethod

## With R8 full mode generic signatures are stripped for classes that are not kept.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

## Keep JSON serialization classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}


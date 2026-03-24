# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Google Play Core (for Flutter dynamic features)
# These classes are optional and only used for Play Store dynamic feature modules
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Supabase
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Gson (if used by Supabase or other dependencies)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# HTTP/Networking
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# SVG rendering
-keep class com.caverock.androidsvg.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Keep generic signatures for reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# For native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all model classes (adjust package name as needed)
-keep class com.devsinntechnologies.smartlogomaker.models.** { *; }

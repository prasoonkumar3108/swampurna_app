# Keep networking models and API classes from obfuscation
-keep class com.example.my_app.** { *; }
-keep class io.flutter.** { *; }

# Keep JSON parsing and HTTP client classes
-keep class com.google.gson.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep data classes and models
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Flutter engine classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Prevent obfuscation of fields that use Gson annotations
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep methods that use reflection
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn okhttp3.**
-dontwarn retrofit2.**

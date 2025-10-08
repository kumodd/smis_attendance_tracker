# Keep all of OkHttp3 + Okio (used by Dio under the hood)
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okio.**
-keep class okio.** { *; }

# Keep Dio models
-keep class dio.** { *; }

# Keep GetX classes (to avoid reflection issues)
-keep class com.sm** { *; }  # replace with your actual package if needed
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

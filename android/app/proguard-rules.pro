# Keep Firebase Messaging classes
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# Keep Firebase common
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Gson (sering dipakai Firebase)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

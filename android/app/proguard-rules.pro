# Mengabaikan error logging SLF4J (Penyebab error Anda)
-dontwarn org.slf4j.**
-dontwarn javax.annotation.**
-keep class org.slf4j.** { *; }

# Tambahan umum untuk Firebase & Flutter
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
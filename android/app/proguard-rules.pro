# REGLAS DE PROTECCION PARA EVITAR QUE R8 ELIMINE CLases DE CAMERAX Y ML KIT EN MODO RELEASE
-keep class androidx.camera.** { *; }
-keep interface androidx.camera.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn androidx.camera.**

